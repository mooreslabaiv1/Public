`include "uvm_macros.svh"
`include "fsm_one_hot_counting_operation_post_sequence_detection_sequence.sv"

// Added definition of the missing base test class to fix the compile error.
class fsm_one_hot_base_test extends uvm_test;
  `uvm_component_utils(fsm_one_hot_base_test)

  fsm_one_hot_env env;
  fsm_one_hot_fsm_agent_base_seqr p_sequencer;

  function new(string name="fsm_one_hot_base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_one_hot_env::type_id::create("env", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p_sequencer = env.fsm_agent.base_sqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask
endclass : fsm_one_hot_base_test

class counting_operation_post_sequence_detection_test extends fsm_one_hot_base_test;
  `uvm_component_utils(counting_operation_post_sequence_detection_test)

  // All variable declarations at the beginning
  function new(string name="counting_operation_post_sequence_detection_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    counting_operation_post_sequence_detection_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = counting_operation_post_sequence_detection_sequence::type_id::create("seq");
    seq.start(p_sequencer);

    phase.drop_objection(this);
  endtask : run_phase

endclass : counting_operation_post_sequence_detection_test