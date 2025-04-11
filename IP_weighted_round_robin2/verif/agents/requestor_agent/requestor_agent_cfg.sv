`ifndef REQUESTOR_AGENT_CFG__SV
`define REQUESTOR_AGENT_CFG__SV

class requestor_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(requestor_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "requestor_config");
    super.new(name);
  endfunction : new

endclass : requestor_agent_cfg

`endif  // REQUESTOR_AGENT_CFG__SV