`ifndef SERIAL_AGENT_COV__SV
`define SERIAL_AGENT_COV__SV

class serial_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(serial_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  serial_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(serial_trans_item, serial_agent_cov) cov_export;

  // Write function implementation
  virtual function void write(serial_trans_item tr);
    this.tr = tr;
    ->cov_event;
  endfunction : write

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_trans = new;
    cov_export = new("Coverage Analysis", this);
  endfunction : new

  //******************************************************************************
  // Covergroups
  //******************************************************************************
  covergroup cg_trans @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans

endclass : serial_agent_cov

`endif  // SERIAL_AGENT_COV__SV