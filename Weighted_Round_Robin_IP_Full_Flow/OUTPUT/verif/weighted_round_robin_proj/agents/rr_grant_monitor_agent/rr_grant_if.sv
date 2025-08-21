
`ifndef RR_GRANT_IF__SV
`define RR_GRANT_IF__SV

interface rr_grant_if (
    input logic clk,
    input logic rst
);

  //******************************************************************************
  // Ports
  //******************************************************************************
logic [31:0] gnt_w;
  logic [4:0] gnt_id;

  //******************************************************************************
  // Clocking Block
  //******************************************************************************
  clocking rr_grant_monitor_cb @(posedge clk);
    default input #1step;
    default output #1;
input gnt_w;
    input gnt_id;
  endclocking : rr_grant_monitor_cb

endinterface : rr_grant_if

`endif  // RR_GRANT_IF__SV