`ifndef RR_REQUEST_AGENT_CFG__SV
`define RR_REQUEST_AGENT_CFG__SV

class rr_request_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(rr_request_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "rr_request_config");
    super.new(name);
  endfunction : new

endclass : rr_request_agent_cfg

`endif  // RR_REQUEST_AGENT_CFG__SV