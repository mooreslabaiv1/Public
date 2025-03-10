
`include "uvm_macros.svh"
`include "priority_encoder_reset_functionality_test_sequence.sv"

`ifndef RESET_FUNCTIONALITY_TEST_TEST_SV
`define RESET_FUNCTIONALITY_TEST_TEST_SV

class reset_functionality_test_test extends uvm_test;
  // Declarations at the beginning of class
  `uvm_component_utils(reset_functionality_test_test)
  priority_encoder_env env;
  reset_functionality_test_sequence seq;

  function new(string name = "reset_functionality_test_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = priority_encoder_env::type_id::create("env", this);
    seq = reset_functionality_test_sequence::type_id::create("seq");
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.priority_encoder_agent.base_sqr);
    phase.drop_objection(this);
  endtask
endclass : reset_functionality_test_test

`endif // RESET_FUNCTIONALITY_TEST_TEST_SV
