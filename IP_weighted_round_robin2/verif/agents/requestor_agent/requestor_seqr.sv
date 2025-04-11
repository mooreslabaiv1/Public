`ifndef REQUESTOR_SEQR__SV
`define REQUESTOR_SEQR__SV

class requestor_seqr extends uvm_sequencer #(requestor_trans_item);

  `uvm_component_utils(requestor_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : requestor_seqr

`endif  // REQUESTOR_SEQR__SV