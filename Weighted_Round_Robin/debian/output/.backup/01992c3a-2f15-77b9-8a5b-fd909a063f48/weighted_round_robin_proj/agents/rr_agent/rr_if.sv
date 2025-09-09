`ifndef RR_IF__SV
`define RR_IF__SV

interface rr_if (
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
  clocking rr_cb @(posedge clk);
    default input #1step;
    default output #1;
output req;
    output ack;
    input gnt_w;
    input gnt_id;
  endclocking : rr_cb

endinterface : rr_if

`endif  // RR_IF__SV