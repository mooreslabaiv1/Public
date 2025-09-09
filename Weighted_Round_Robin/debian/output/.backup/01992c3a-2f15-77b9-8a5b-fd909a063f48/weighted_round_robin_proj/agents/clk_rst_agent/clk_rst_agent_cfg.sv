`ifndef CLK_RST_AGENT_CFG__SV
`define CLK_RST_AGENT_CFG__SV
class clk_rst_agent_cfg extends uvm_object;

  // Register with factory
  `uvm_object_utils(clk_rst_agent_cfg)

  /// Agent Active or Passive ///
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /// Agent Include Functional Coverage Monitor ///
  bit has_functional_coverage = 1;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "clk_rst_agent_cfg");
    super.new(name);
  endfunction : new

endclass : clk_rst_agent_cfg

`endif  // CLK_RST_AGENT_CFG__SV