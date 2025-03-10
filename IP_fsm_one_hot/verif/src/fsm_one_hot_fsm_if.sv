


`ifndef FSM_ONE_HOT_FSM_IF__SV
`define FSM_ONE_HOT_FSM_IF__SV

interface fsm_if (
  input  logic clk,
  input  logic rst
);

  logic d;
  logic done_counting;
  logic ack;
  logic done;
  logic counting;
  logic shift_ena;

endinterface : fsm_if
`endif // FSM_ONE_HOT_FSM_IF__SV