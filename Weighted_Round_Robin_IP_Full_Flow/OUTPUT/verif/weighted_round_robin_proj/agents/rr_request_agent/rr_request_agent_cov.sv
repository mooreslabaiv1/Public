

`ifndef RR_REQUEST_AGENT_COV__SV
`define RR_REQUEST_AGENT_COV__SV

class rr_request_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(rr_request_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  rr_request_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(rr_request_trans_item, rr_request_agent_cov) cov_export;

  // Covergroup instance
  covergroup cg_trans_h @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans_h

  // Write function implementation
  virtual function void write(rr_request_trans_item tr);
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

endclass : rr_request_agent_cov

`endif  // RR_REQUEST_AGENT_COV__SV