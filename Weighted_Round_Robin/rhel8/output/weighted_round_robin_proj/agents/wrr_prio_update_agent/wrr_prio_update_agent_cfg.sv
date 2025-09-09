`ifndef WRR_PRIO_UPDATE_AGENT_CFG__SV
`define WRR_PRIO_UPDATE_AGENT_CFG__SV

class wrr_prio_update_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(wrr_prio_update_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "wrr_prio_update_config");
    super.new(name);
  endfunction : new

endclass : wrr_prio_update_agent_cfg

`endif  // WRR_PRIO_UPDATE_AGENT_CFG__SV