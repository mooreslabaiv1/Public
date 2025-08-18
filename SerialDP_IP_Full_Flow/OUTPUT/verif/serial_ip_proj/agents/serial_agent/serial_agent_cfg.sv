`ifndef SERIAL_AGENT_CFG__SV
`define SERIAL_AGENT_CFG__SV

class serial_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(serial_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "serial_config");
    super.new(name);
  endfunction : new

endclass : serial_agent_cfg

`endif  // SERIAL_AGENT_CFG__SV