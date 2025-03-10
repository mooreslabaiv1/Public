


`include "uvm_macros.svh"
`include "fsm_seek_detect_overlappingsequencetest_sequence.sv"

class overlappingsequencetest_test extends uvm_test;
  `uvm_component_utils(overlappingsequencetest_test)

  fsm_seek_detect_env env;

  function new(string name="overlappingsequencetest_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_seek_detect_env::type_id::create("env", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    overlappingsequencetest_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = overlappingsequencetest_sequence::type_id::create("seq");
    seq.start(env.fsm_seek_detect_agent.base_sqr);

    phase.drop_objection(this);
  endtask : run_phase

endclass : overlappingsequencetest_test