

`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_IF__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_IF__SV

// -----------------------------------------------------------------------------
// {+++++ <Modify the below interface code as needed> +++++}
interface priority_encoder_if (input logic clk, input logic rst);

  // Interface signal declarations
  logic [3:0] in = 4'b0000; // Initialize to 0
  logic [1:0] pos;

endinterface : priority_encoder_if
`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_IF__SV