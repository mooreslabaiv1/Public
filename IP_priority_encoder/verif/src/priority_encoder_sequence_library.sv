

`ifndef PRIORITY_ENCODER_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define PRIORITY_ENCODER_BASE_SEQR_SEQUENCE_LIBRARY__SV


typedef class priority_encoder_priority_encoder_agent_base_transaction;
class priority_encoder_base_seqr_sequence_library extends uvm_sequence_library # (priority_encoder_priority_encoder_agent_base_transaction);
  
  `uvm_object_utils(priority_encoder_base_seqr_sequence_library)
  `uvm_sequence_library_utils(priority_encoder_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

`endif // PRIORITY_ENCODER_BASE_SEQR_SEQUENCE_LIBRARY__SV