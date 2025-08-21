
`ifndef RR_GRANT_MONITOR_SEQR__SV
`define RR_GRANT_MONITOR_SEQR__SV

class rr_grant_monitor_seqr extends uvm_sequencer #(rr_grant_monitor_trans_item);

  `uvm_component_utils(rr_grant_monitor_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : rr_grant_monitor_seqr

`endif  // RR_GRANT_MONITOR_SEQR__SV