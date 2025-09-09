`ifndef WRR_PRIO_UPDATE_AGENT_COV__SV
`define WRR_PRIO_UPDATE_AGENT_COV__SV

class wrr_prio_update_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(wrr_prio_update_agent_cov)

  // Member declarations
  event cov_event;
  wrr_prio_update_trans_item tr;
  uvm_analysis_imp #(wrr_prio_update_trans_item, wrr_prio_update_agent_cov) cov_export;

  //******************************************************************************
  // Covergroups
  //******************************************************************************
  covergroup cg_trans @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans

  // Write function implementation
  virtual function void write(wrr_prio_update_trans_item tr);
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

endclass : wrr_prio_update_agent_cov

`endif  // WRR_PRIO_UPDATE_AGENT_COV__SV