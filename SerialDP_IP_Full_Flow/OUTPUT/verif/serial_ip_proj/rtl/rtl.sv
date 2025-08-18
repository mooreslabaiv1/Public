`timescale 1ns/1ps

module serialDP(
    input  wire       clk,
    input  wire       in,
    input  wire       reset,    // Synchronous reset
    output reg  [7:0] out_byte, // Captured data byte
    output reg        done      // Asserted for 1 cycle when a valid byte is received
);

    // -------------------------
    // Instantiate parity module
    // -------------------------
    wire odd_parity;
    reg  parity_reset; // Will be pulsed high when we detect the start bit

    // We'll only feed the data bits + parity bit into the parity checker.
    // The start bit (always 0) and the stop bit (always 1) should NOT affect parity.
    // So we create a gated signal that is 'in' only when we are in DATA or PARITY states.
    wire parity_in;    


    // Counter for 8 data bits
    reg [3:0] bit_count;

    // -------------------------
    // State machine definition
    // -------------------------

    typedef enum reg [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP,
        WAIT_STOP
    } state_t;


    state_t state, next_state;


    // We'll assign this below in the sequential block or in a combinational block:
    // parity_in = (state == DATA || state == PARITY) ? in : 1'b0;
    assign parity_in = ( (state == DATA) || (state == PARITY) ) ? in : 1'b0;


    parity p0 (
        .clk   (clk),
        .reset (parity_reset),
        .in    (parity_in),
        .odd   (odd_parity)
    );


    // -------------------------
    // Next-state logic
    // -------------------------
    always @(*) begin
        next_state = state;  // Default: remain in same state

        case (state)
            IDLE: begin
                // Wait for start bit (line low)
                if (in == 1'b0)
                    next_state = START;
            end

            START: begin
                // Move to DATA after 1 cycle in START
                next_state = DATA;
            end

            DATA: begin
                // Collect 8 bits
                if (bit_count == 4'd7)
                    next_state = PARITY;  // After 8 data bits, go get parity bit
                else
                    next_state = DATA;
            end

            PARITY: begin
                // Single parity bit. Next cycle, check stop bit.
                next_state = STOP;
            end

            STOP: begin
                // Check if stop bit is 1. If not, we must wait until it goes high.
                if (in == 1'b1)
                    next_state = IDLE;   // If line is high, go idle
                else
                    next_state = WAIT_STOP;
            end

            WAIT_STOP: begin
                // Stay here until the line goes high to re-sync
                if (in == 1'b1)
                    next_state = IDLE;
            end

            // default: next_state = IDLE; // Not strictly needed for an enum
        endcase
    end

    // -------------------------
    // Sequential block
    // -------------------------
    always @(posedge clk) begin
        if (reset) begin
            state       <= IDLE;
            bit_count   <= 4'd0;
            out_byte    <= 8'd0;
            done        <= 1'b0;
            parity_reset <= 1'b1;  // Reset the TFF on system reset
        end
        else begin
            // Default outputs each clock
            done         <= 1'b0;
            parity_reset <= 1'b0;

            state <= next_state;

            case (state)
                IDLE: begin
                    // Clear counters, outputs
                    bit_count <= 4'd0;
                end

                START: begin
                    // We've just recognized a start bit
                    // Reset the parity checker for this upcoming byte
                    parity_reset <= 1'b1;  
                    // Clear out_byte to start collecting data
                    out_byte    <= 8'd0;
                end

                DATA: begin
                    // Shift in the LSB first
                    // The first received data bit goes to out_byte[0], etc.
                    // out_byte  <= {in, out_byte[7:1]};
                    out_byte <= {out_byte[6:0], in}; 
                    bit_count <= bit_count + 1;
                end

                PARITY: begin
                    // Here, 'in' is the parity bit, automatically toggling parity checker
                    // No need to store it in out_byte.
                    // Move to STOP next cycle
                end

                STOP: begin
                    // If stop bit == 1 and the overall parity was correct (odd_parity == 1),
                    // then we have a valid byte
                    if (in == 1'b1 && odd_parity == 1'b1) begin
                        done <= 1'b1;  // Good frame + correct parity
                    end
                    // If in == 1'b0 (bad stop bit) or odd_parity == 0 (bad parity),
                    // we do not assert done. Next_state logic moves us to WAIT_STOP or IDLE.
                end

                WAIT_STOP: begin
                    // Wait until line is high, then we’ll return to IDLE in next_state.
                end
            endcase
        end
    end

endmodule

module parity (
    input clk,
    input reset,
    input in,
    output reg odd);

    always @(posedge clk)
        if (reset) odd <= 0;
        else if (in) odd <= ~odd;

endmodule