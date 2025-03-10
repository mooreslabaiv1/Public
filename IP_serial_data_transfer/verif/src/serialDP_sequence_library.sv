


`ifndef SERIALDP_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define SERIALDP_BASE_SEQR_SEQUENCE_LIBRARY__SV


typedef class serialDP_serial_agent_base_transaction;
class serialDP_base_seqr_sequence_library extends uvm_sequence_library # (serialDP_serial_agent_base_transaction);
  
  `uvm_object_utils(serialDP_base_seqr_sequence_library)
  `uvm_sequence_library_utils(serialDP_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

`endif // SERIALDP_BASE_SEQR_SEQUENCE_LIBRARY__SV