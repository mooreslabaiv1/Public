`ifndef WRR_PRIO_UPDATE_SEQR__SV
`define WRR_PRIO_UPDATE_SEQR__SV

class wrr_prio_update_seqr extends uvm_sequencer #(wrr_prio_update_trans_item);

  `uvm_component_utils(wrr_prio_update_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : wrr_prio_update_seqr

`endif  // WRR_PRIO_UPDATE_SEQR__SV