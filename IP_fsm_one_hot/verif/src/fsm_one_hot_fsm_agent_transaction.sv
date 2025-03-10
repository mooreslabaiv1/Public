`ifndef FSM_ONE_HOT_FSM_AGENT_TRANSACTION__SV
`define FSM_ONE_HOT_FSM_AGENT_TRANSACTION__SV

class fsm_one_hot_fsm_agent_base_transaction extends uvm_sequence_item;

  rand logic d;
  rand logic done_counting;
  rand logic ack;

  constraint handshake_constraint {
    !(done_counting && ack);
  }

  `uvm_object_utils_begin(fsm_one_hot_fsm_agent_base_transaction)
    `uvm_field_int(d, UVM_ALL_ON)
    `uvm_field_int(done_counting, UVM_ALL_ON)
    `uvm_field_int(ack, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fsm_transaction");
    super.new(name);
  endfunction: new

endclass: fsm_one_hot_fsm_agent_base_transaction


`endif // FSM_ONE_HOT_FSM_AGENT_TRANSACTION__SV
