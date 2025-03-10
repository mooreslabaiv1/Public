
module fsm_one_hot(
    input  logic clk,              // Clock input
    input  logic rst,              // Reset input
    input  logic d,                // Input data
    input  logic done_counting,    // Counter completion signal
    input  logic ack,              // Acknowledgment signal
    output logic done,             // Operation complete
    output logic counting,         // Counter active
    output logic shift_ena         // Shift enable
);

    // State parameter definitions
    parameter S=0, S1=1, S11=2, S110=3, B0=4, B1=5, B2=6, B3=7, Count=8, Wait=9;
    
    // State register - one-hot encoded
    logic [9:0] state, next_state;

    // State register with synchronous reset
    always_ff @(posedge clk) begin
        if (rst)
            state <= 10'b0000000001;  // Reset to initial state S
        else
            state <= next_state;
    end

    // Next state logic - based on state diagram
    always_comb begin
        // Default: maintain current state
        next_state = '0;  // Clear all bits

        case (1'b1)  // synthesis parallel_case full_case
            // Initial state - looking for first '1'
            state[S]: begin
                if (d)
                    next_state[S1] = 1'b1;    // Got '1', move to S1
                else
                    next_state[S] = 1'b1;     // Stay in S
            end

            // Looking for second '1'
            state[S1]: begin
                if (d)
                    next_state[S11] = 1'b1;   // Got '1', move to S11
                else
                    next_state[S] = 1'b1;     // Back to S
            end

            // Looking for '0'
            state[S11]: begin
                if (!d)
                    next_state[S110] = 1'b1;  // Got '0', move to S110
                else
                    next_state[S11] = 1'b1;   // Stay in S11
            end

            // Looking for final '1'
            state[S110]: begin
                if (d)
                    next_state[B0] = 1'b1;    // Got '1', sequence complete
                else
                    next_state[S] = 1'b1;     // Back to S
            end

            // Bit count states
            state[B0]: next_state[B1] = 1'b1;    // Move through bit
            state[B1]: next_state[B2] = 1'b1;    // counting states
            state[B2]: next_state[B3] = 1'b1;    // one by one
            state[B3]: next_state[Count] = 1'b1;  // To counting state

            // Counter active state
            state[Count]: begin
                if (done_counting)
                    next_state[Wait] = 1'b1;   // Counter done
                else
                    next_state[Count] = 1'b1;  // Keep counting
            end

            // Wait for acknowledgment
            state[Wait]: begin
                if (ack)
                    next_state[S] = 1'b1;      // Got ack, back to start
                else
                    next_state[Wait] = 1'b1;   // Keep waiting
            end

            // Recovery from invalid states
            default: next_state[S] = 1'b1;
        endcase
    end

    // Output logic - direct from state bits
    assign done = state[Wait];               // Completed when in Wait state
    assign counting = state[Count];          // Active during Count state
    assign shift_ena = |state[B3:B0];        // Active during bit count states

endmodule