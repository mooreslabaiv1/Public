




`include "uvm_macros.svh"
`include "fsm_seek_detect_basicfunctionalitytest_sequence.sv"

class basicfunctionalitytest_test extends uvm_test;

  `uvm_component_utils(basicfunctionalitytest_test)

  fsm_seek_detect_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_seek_detect_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fsm_seek_detect_basicfunctionalitytest_sequence seq;
    phase.raise_objection(this);
    seq = new("basicfunctionalitytest_sequence");
    seq.start(env.fsm_seek_detect_agent.base_sqr);
    phase.drop_objection(this);
  endtask

endclass: basicfunctionalitytest_test