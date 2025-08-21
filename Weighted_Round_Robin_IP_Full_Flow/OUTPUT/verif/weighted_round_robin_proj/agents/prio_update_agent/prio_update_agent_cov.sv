

`ifndef PRIO_UPDATE_AGENT_COV__SV
`define PRIO_UPDATE_AGENT_COV__SV

class prio_update_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(prio_update_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  prio_update_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(prio_update_trans_item, prio_update_agent_cov) cov_export;

  // Covergroup instance
  covergroup cg_trans_h @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans_h

  // Write function implementation
  virtual function void write(prio_update_trans_item tr);
    this.tr = tr;
    ->cov_event;
  endfunction : write

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_trans_h = new;
    cov_export = new("Coverage Analysis", this);
  endfunction : new

endclass : prio_update_agent_cov

`endif  // PRIO_UPDATE_AGENT_COV__SV