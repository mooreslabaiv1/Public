



`ifndef FSM_ONE_HOT_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define FSM_ONE_HOT_BASE_SEQR_SEQUENCE_LIBRARY__SV


typedef class fsm_one_hot_fsm_agent_base_transaction;
class fsm_one_hot_base_seqr_sequence_library extends uvm_sequence_library # (fsm_one_hot_fsm_agent_base_transaction);
  
  `uvm_object_utils(fsm_one_hot_base_seqr_sequence_library)
  `uvm_sequence_library_utils(fsm_one_hot_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  


// Base sequence class for all testcases
class fsm_one_hot_base_sequence extends uvm_sequence #(fsm_one_hot_fsm_agent_base_transaction);
  `uvm_object_utils(fsm_one_hot_base_sequence)

  function new(string name = "fsm_one_hot_base_sequence");
    super.new(name);
  endfunction: new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask: pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask: post_body
  `endif

  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting");
  endtask: pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending");
  endtask: post_start
  `endif
endclass : fsm_one_hot_base_sequence


`endif // FSM_ONE_HOT_BASE_SEQR_SEQUENCE_LIBRARY__SV