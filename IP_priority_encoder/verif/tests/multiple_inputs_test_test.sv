


`include "uvm_macros.svh"


class multiple_inputs_test_test extends uvm_test;
  `uvm_component_utils(multiple_inputs_test_test)

  priority_encoder_env env;

  function new(string name="", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = priority_encoder_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    multiple_inputs_test_sequence seq;
    phase.raise_objection(this);
    seq = multiple_inputs_test_sequence::type_id::create("seq");
    seq.start(env.priority_encoder_agent.base_sqr);
    phase.drop_objection(this);
  endtask
endclass