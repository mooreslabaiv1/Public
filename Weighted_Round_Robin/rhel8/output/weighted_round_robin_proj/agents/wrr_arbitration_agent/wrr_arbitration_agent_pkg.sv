package wrr_arbitration_agent_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "wrr_arbitration_trans_item.sv"
  `include "wrr_arbitration_monitor.sv"
  `include "wrr_arbitration_driver.sv"
  `include "wrr_arbitration_seqr.sv"
  `include "wrr_arbitration_agent_cov.sv"
  `include "wrr_arbitration_agent_cfg.sv"
  `include "wrr_arbitration_agent.sv"

endpackage : wrr_arbitration_agent_pkg