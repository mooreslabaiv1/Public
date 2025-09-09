`ifndef WRR_ARBITRATION_SEQR__SV
`define WRR_ARBITRATION_SEQR__SV

class wrr_arbitration_seqr extends uvm_sequencer #(wrr_arbitration_trans_item);

  `uvm_component_utils(wrr_arbitration_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : wrr_arbitration_seqr

`endif  // WRR_ARBITRATION_SEQR__SV