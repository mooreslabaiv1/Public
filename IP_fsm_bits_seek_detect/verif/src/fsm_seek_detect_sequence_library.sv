


`ifndef FSM_SEEK_DETECT_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define FSM_SEEK_DETECT_BASE_SEQR_SEQUENCE_LIBRARY__SV


typedef class fsm_seek_detect_fsm_seek_detect_agent_base_transaction;
class fsm_seek_detect_base_seqr_sequence_library extends uvm_sequence_library # (fsm_seek_detect_fsm_seek_detect_agent_base_transaction);
  
  `uvm_object_utils(fsm_seek_detect_base_seqr_sequence_library)
  `uvm_sequence_library_utils(fsm_seek_detect_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

// BASE SEQUENCE CLASS (Fundamental Sequence for All Test Cases)
class base_sequence extends uvm_sequence#(fsm_seek_detect_fsm_seek_detect_agent_base_transaction);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Executing base sequence body.", UVM_LOW)
  endtask

endclass

`endif