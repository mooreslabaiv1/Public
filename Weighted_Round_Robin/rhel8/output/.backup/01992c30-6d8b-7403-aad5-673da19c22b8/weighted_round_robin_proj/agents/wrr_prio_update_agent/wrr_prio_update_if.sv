`ifndef WRR_PRIO_UPDATE_IF__SV
`define WRR_PRIO_UPDATE_IF__SV

interface wrr_prio_update_if (
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
  clocking wrr_prio_update_cb @(posedge clk);
    default input #1step;
    default output #1;
output prio;
    output prio_id;
    output prio_upt;
  endclocking : wrr_prio_update_cb

endinterface : wrr_prio_update_if

`endif  // WRR_PRIO_UPDATE_IF__SV