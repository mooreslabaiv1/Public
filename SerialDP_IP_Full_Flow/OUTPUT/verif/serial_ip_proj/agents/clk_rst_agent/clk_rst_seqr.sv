`ifndef CLK_RST_SEQR__SV
`define CLK_RST_SEQR__SV

class clk_rst_seqr extends uvm_sequencer #(clk_rst_trans_item);
  `uvm_component_utils(clk_rst_seqr)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : clk_rst_seqr

`endif  // CLK_RST_SEQR__SV