

`ifndef RR_GRANT_MONITOR_AGENT_COV__SV
`define RR_GRANT_MONITOR_AGENT_COV__SV

class rr_grant_monitor_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(rr_grant_monitor_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  rr_grant_monitor_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(rr_grant_monitor_trans_item, rr_grant_monitor_agent_cov) cov_export;

  // Covergroup instance
  covergroup cg_trans_h @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans_h

  // Write function implementation
  virtual function void write(rr_grant_monitor_trans_item tr);
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

endclass : rr_grant_monitor_agent_cov

`endif  // RR_GRANT_MONITOR_AGENT_COV__SV