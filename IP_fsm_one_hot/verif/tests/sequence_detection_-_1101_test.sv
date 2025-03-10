



`include "uvm_macros.svh"
`include "fsm_one_hot_sequence_detection_-_1101_sequence.sv"

class sequence_detection_1101_test extends uvm_test;
  `uvm_component_utils(sequence_detection_1101_test)

  // Declarations at the beginning
  fsm_one_hot_sequence_detection_1101_sequence seq_obj;
  fsm_one_hot_env env;

  function new(string name = "sequence_detection_1101_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_one_hot_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    seq_obj = fsm_one_hot_sequence_detection_1101_sequence::type_id::create("seq_obj");
    seq_obj.start(env.fsm_agent.base_sqr);

    phase.drop_objection(this);
  endtask

endclass : sequence_detection_1101_test