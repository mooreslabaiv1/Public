`ifndef PRIO_IF__SV
`define PRIO_IF__SV

interface prio_if (
    input logic clk,
    input logic rst
);

  //******************************************************************************
  // Ports
  //******************************************************************************
logic [3:0] prio;
  logic [4:0] prio_id;
  logic prio_upt;

  //******************************************************************************
  // Clocking Block
  //******************************************************************************
  clocking prio_update_cb @(posedge clk);
    default input #1step;
    default output #1;
output prio;
    output prio_id;
    output prio_upt;
  endclocking : prio_update_cb

endinterface : prio_if

`endif  // PRIO_IF__SV