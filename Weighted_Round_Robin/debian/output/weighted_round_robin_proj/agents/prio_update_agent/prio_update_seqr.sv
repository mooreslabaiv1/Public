`ifndef PRIO_UPDATE_SEQR__SV
`define PRIO_UPDATE_SEQR__SV

class prio_update_seqr extends uvm_sequencer #(prio_update_trans_item);

  `uvm_component_utils(prio_update_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : prio_update_seqr

`endif  // PRIO_UPDATE_SEQR__SV