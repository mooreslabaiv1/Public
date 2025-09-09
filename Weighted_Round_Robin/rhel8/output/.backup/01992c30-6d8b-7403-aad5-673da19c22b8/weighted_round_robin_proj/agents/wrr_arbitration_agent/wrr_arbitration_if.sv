`ifndef WRR_ARBITRATION_IF__SV
`define WRR_ARBITRATION_IF__SV

interface wrr_arbitration_if (
    input logic clk,
    input logic rst
);

  //******************************************************************************
  // Ports
  //******************************************************************************
logic [31:0] req;
  logic ack;
  logic [31:0] gnt_w;
  logic [4:0] gnt_id;

  //******************************************************************************
  // Clocking Block
  //******************************************************************************
  clocking wrr_arbitration_cb @(posedge clk);
    default input #1step;
    default output #1;
output req;
    output ack;
    input gnt_w;
    input gnt_id;
  endclocking : wrr_arbitration_cb

endinterface : wrr_arbitration_if

`endif  // WRR_ARBITRATION_IF__SV