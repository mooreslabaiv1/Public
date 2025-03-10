

`ifndef FULL_FSM_TRAVERSAL_TEST_SV
`define FULL_FSM_TRAVERSAL_TEST_SV

`include "uvm_macros.svh"
`include "fsm_one_hot_full_fsm_traversal_sequence.sv"

class full_fsm_traversal_test extends fsm_one_hot_base_test;
  `uvm_component_utils(full_fsm_traversal_test)

  function new(string name="full_fsm_traversal_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    full_fsm_traversal_sequence seq;
    seq = full_fsm_traversal_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(p_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : full_fsm_traversal_test

`endif // FULL_FSM_TRAVERSAL_TEST_SV