module top_module (
    input [3:0] in,
    input clk,
    input reset,
    output reg [1:0] pos
);

// Register to hold the chosen output
reg [1:0] pos_ff;

// Combinational logic to determine the priority encoding
always @(*) begin
    if (in === 4'bxxxx) begin
        pos_ff = 2'd0; // Handle undefined 'in'
    end else begin
        casez (in)
            4'b???1: pos_ff = 2'd0; // Lowest priority (bit 0)
            4'b??10: pos_ff = 2'd1; // Next priority (bit 1)
            4'b?100: pos_ff = 2'd2; // Next priority (bit 2)
            4'b1000: pos_ff = 2'd3; // Highest priority (bit 3)
            default: pos_ff = 2'd0; // Default when all inputs are zero
        endcase
    end
end

// Sequential logic: store the output in a flip-flop and reset logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pos <= 2'd0; // Reset the flip-flop output to 0
    end else begin
        pos <= pos_ff; // Update the flip-flop output on the clock edge
    end
end

endmodule
