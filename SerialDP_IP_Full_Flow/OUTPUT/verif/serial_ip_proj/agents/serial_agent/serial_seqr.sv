

`ifndef SERIAL_SEQR__SV
`define SERIAL_SEQR__SV

class serial_seqr extends uvm_sequencer #(serial_trans_item);

  `uvm_component_utils(serial_seqr)

  virtual serial_if vif;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function virtual serial_if get_virtual_interface();
    return vif;
  endfunction : get_virtual_interface

endclass : serial_seqr

`endif  // SERIAL_SEQR__SV