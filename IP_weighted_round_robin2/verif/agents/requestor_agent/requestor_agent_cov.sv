`ifndef REQUESTOR_AGENT_COV__SV
`define REQUESTOR_AGENT_COV__SV

class requestor_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(requestor_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  requestor_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(requestor_trans_item, requestor_agent_cov) cov_export;

  // Write function implementation
  virtual function void write(requestor_trans_item tr);
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

endclass : requestor_agent_cov

`endif  // REQUESTOR_AGENT_COV__SV