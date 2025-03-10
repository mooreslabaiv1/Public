// *** Start of the file - fsm_seek_detect.sv

module fsm_seek_detect (
    input  logic clk,
    input  logic aresetn,    // Asynchronous active-low reset
    input  logic x,          // Input signal
    output logic z           // Output signal, asserted when "101" detected
);

    // State encoding
    typedef enum logic [1:0] {
        S0 = 2'b00,  // Initial state, waiting for first '1'
        S1 = 2'b01,  // Received '1', waiting for '0'
        S2 = 2'b10   // Received '0', waiting for final '1'
    } state_t;

    state_t current_state, next_state;

    // State register with asynchronous reset
    always_ff @(posedge clk or negedge aresetn) begin
        if (!aresetn)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (current_state)
            S0: next_state = x ? S1 : S0;  // If 1, go to S1; else stay in S0
            S1: next_state = x ? S1 : S2;  // If 1, stay in S1; if 0, go to S2
            S2: next_state = x ? S1 : S0;  // If 1, go to S1; if 0, go to S0
            default: next_state = S0;
        endcase
    end

    // Output logic (Mealy output depends on current state and input)
    assign z = (current_state == S2) && x;  // Assert z when in S2 and input is 1

endmodule

// *** End of the file - fsm_seek_detect.sv

