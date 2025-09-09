`ifndef RR_AGENT_COV__SV
`define RR_AGENT_COV__SV

class rr_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(rr_agent_cov)

  // Member declarations
  event cov_event;
  rr_trans_item tr;
  uvm_analysis_imp #(rr_trans_item, rr_agent_cov) cov_export;

  //******************************************************************************
  // Covergroups
  //******************************************************************************
  covergroup cg_trans @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans

  // Write function implementation
  virtual function void write(rr_trans_item tr);
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

endclass : rr_agent_cov

`endif  // RR_AGENT_COV__SV