// *** Start of the file - full_rtl.sv

// *** Start of the file - rtl.sv

module serialDP(
    input  wire       clk,
    input  wire       in,
    input  wire       reset,    // Synchronous reset
    output reg  [7:0] out_byte, // Captured data byte
    output            done      // Asserted when final stop bit is seen
);

    // ---------------------------------------------------------
    // State definitions
    // i = idle, r = receive (start + 8 data + 1 parity), dp = check stop,
    // d = done, e = error
    // ---------------------------------------------------------
    parameter i = 0,
              r = 1,
              d = 2,
              e = 3,
              dp= 4;

    reg [2:0] state, next;
    reg       odd;   // T-flop parity
    int       cnt;   // Counts from 0..9 in state r

    // ---------------------------------------------------------
    // T-flip-flop parity module
    // Toggles 'odd' on each 'in==1' if not reset
    // ---------------------------------------------------------
    parity p_check (
        .clk  (clk),
        .reset(~(state == r)), // reset 'odd' except when in 'r'
        .in   (in),
        .odd  (odd)
    );

    // ---------------------------------------------------------
    // Next-state logic (combinational)
    // ---------------------------------------------------------
    always @(*) begin
        next = state;
        case (state)
            // Idle, wait for start bit (in == 0)
            i: begin
                if (~in)
                    next = r; 
                else
                    next = i;
            end

            // Receiving bits (start=0, data=8 bits, parity=1 bit)
            r: begin
                // Once cnt==9, we've just seen the parity bit
                // The design wants parity bit = ~odd
                if (cnt == 9) begin
                    if (in == ~odd)
                        next = dp; // good parity => check stop bit
                    else
                        next = e;  // parity mismatch => error
                end
                else
                    next = r;     // keep receiving
            end

            // dp: check stop bit = 1 => done, else error
            dp: begin
                next = (in) ? d : e; 
            end

            // d: done state => if line goes low => new frame, else idle
            d: begin
                if (~in)
                    next = r; 
                else
                    next = i;
            end

            // e: error => wait for line=1 => idle
            e: begin
                if (in)
                    next = i;
                else
                    next = e;
            end
        endcase
    end

    // ---------------------------------------------------------
    // Sequential block: update state, capture bits
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            state    <= i;
            out_byte <= 8'b0;
            cnt      <= 0;
        end 
        else begin
            state <= next;
            case (next)
                r: begin
                    // We are receiving bits
                    cnt <= cnt + 1;

                    // cnt=0 => start bit (ignored)
                    // cnt=1..8 => data bits => store LSB-first
                    // cnt=9 => parity bit => do not store
                    if (cnt >= 1 && cnt <= 8) begin
                        out_byte[cnt-1] <= in; 
                    end
                end

                // dp / d / e => reset cnt
                dp, d, e: begin
                    cnt <= 0;
                end

                // i => do nothing special
            endcase
        end
    end

    // ---------------------------------------------------------
    // done = 1 if we are in state d
    // ---------------------------------------------------------
    assign done = (state == d);

endmodule

// ---------------------------------------------------------
// parity module
// toggles 'odd' on each rising edge if in==1, else no toggle
// resets if .reset is 1
// ---------------------------------------------------------
module parity (
    input  wire clk,
    input  wire reset,
    input  wire in,
    output reg  odd 
);
    reg test;


    always @(posedge clk or posedge in) begin
        test = (reset==1) ? 0 : ((in==1) ? ~test: test); 
    end

    always @(posedge clk) begin
        if (reset)
            odd <= 1'b0;
        else if (in)
            odd <= ~odd;
    end

endmodule


// *** End of the file - rtl.sv



// *** End of the file - full_rtl.sv

