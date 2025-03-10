`ifndef FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_SEQUENCE__SV
`define FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_SEQUENCE__SV

`include "uvm_macros.svh"

class fsm_one_hot_reset_functionality_check_sequence extends fsm_one_hot_base_sequence;
  `uvm_object_utils(fsm_one_hot_reset_functionality_check_sequence)
  `uvm_declare_p_sequencer(fsm_one_hot_fsm_agent_base_seqr)

  function new(string name = "fsm_one_hot_reset_functionality_check_sequence");
    super.new(name);
  endfunction : new

  task body();
    fsm_one_hot_fsm_agent_base_transaction init_tr;
    fsm_one_hot_fsm_agent_base_transaction dummy_tr;

    // 1) Create & send a basic transaction
    init_tr = fsm_one_hot_fsm_agent_base_transaction::type_id::create("init_tr");

    start_item(init_tr);
    finish_item(init_tr);

    // 2) Wait 3 cycles
    repeat(3) @(posedge p_sequencer.fsm_vif.clk);

    // 3) Wait 1 more cycle
    repeat(1) @(posedge p_sequencer.fsm_vif.clk);

    // 4) Create & send another transaction
    dummy_tr = fsm_one_hot_fsm_agent_base_transaction::type_id::create("dummy_tr");

    start_item(dummy_tr);
    finish_item(dummy_tr);
  endtask : body

endclass : fsm_one_hot_reset_functionality_check_sequence

`endif // FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_SEQUENCE__SV
