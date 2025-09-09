`ifndef RR_SEQR__SV
`define RR_SEQR__SV

class rr_seqr extends uvm_sequencer #(rr_trans_item);

  `uvm_component_utils(rr_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : rr_seqr

`endif  // RR_SEQR__SV