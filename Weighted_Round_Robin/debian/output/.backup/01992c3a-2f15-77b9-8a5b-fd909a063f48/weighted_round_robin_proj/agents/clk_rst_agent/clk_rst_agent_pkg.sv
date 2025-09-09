package clk_rst_agent_pkg;

  //******************************************************************************
  // Constants, classes, types, etc.
  //******************************************************************************
  typedef enum {
    RST_APPLY,
    CLK_SET,
    WAIT_CYCLES
  } op_type_t;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "clk_rst_trans_item.sv"
  `include "clk_rst_monitor.sv"
  `include "clk_rst_driver.sv"
  `include "clk_rst_seqr.sv"
  `include "clk_rst_agent_cov.sv"
  `include "clk_rst_agent_cfg.sv"
  `include "clk_rst_agent.sv"

endpackage : clk_rst_agent_pkg