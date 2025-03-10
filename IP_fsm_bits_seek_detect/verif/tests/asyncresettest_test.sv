

`include "uvm_macros.svh"
`include "fsm_seek_detect_asyncresettest_sequence.sv"

class asyncresettest_test extends uvm_test;
  `uvm_component_utils(asyncresettest_test)

  fsm_seek_detect_env env;

  function new(string name="", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_seek_detect_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    fsm_seek_detect_asyncresettest_sequence seq;
    phase.raise_objection(this);
    seq = fsm_seek_detect_asyncresettest_sequence::type_id::create("seq");
    seq.start(env.fsm_seek_detect_agent.base_sqr);
    phase.drop_objection(this);
  endtask

endclass