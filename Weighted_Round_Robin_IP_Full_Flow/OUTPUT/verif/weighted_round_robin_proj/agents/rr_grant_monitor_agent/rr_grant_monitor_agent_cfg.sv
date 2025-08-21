
`ifndef RR_GRANT_MONITOR_AGENT_CFG__SV
`define RR_GRANT_MONITOR_AGENT_CFG__SV

class rr_grant_monitor_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(rr_grant_monitor_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "rr_grant_monitor_config");
    super.new(name);
  endfunction : new

endclass : rr_grant_monitor_agent_cfg

`endif  // RR_GRANT_MONITOR_AGENT_CFG__SV