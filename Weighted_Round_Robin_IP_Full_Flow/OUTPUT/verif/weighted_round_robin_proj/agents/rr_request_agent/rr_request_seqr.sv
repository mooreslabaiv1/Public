`ifndef RR_REQUEST_SEQR__SV
`define RR_REQUEST_SEQR__SV

class rr_request_seqr extends uvm_sequencer #(rr_request_trans_item);

  `uvm_component_utils(rr_request_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : rr_request_seqr

`endif  // RR_REQUEST_SEQR__SV