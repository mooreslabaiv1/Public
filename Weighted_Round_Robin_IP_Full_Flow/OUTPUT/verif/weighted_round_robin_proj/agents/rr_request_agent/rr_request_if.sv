`ifndef RR_REQUEST_IF__SV
`define RR_REQUEST_IF__SV

interface rr_request_if (
    input logic clk,
    input logic rst
);

  //******************************************************************************
  // Ports
  //******************************************************************************
logic [31:0] req;
  logic ack;

  //******************************************************************************
  // Clocking Block
  //******************************************************************************
  clocking rr_request_cb @(posedge clk);
    default input #1step;
    default output #1;
output req;
    output ack;
  endclocking : rr_request_cb

endinterface : rr_request_if

`endif  // RR_REQUEST_IF__SV