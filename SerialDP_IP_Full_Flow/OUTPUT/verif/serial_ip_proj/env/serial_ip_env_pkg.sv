package serial_ip_env_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import serial_agent_pkg::*;
    import clk_rst_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "serial_ip_scoreboard.sv"
  `include "serial_ip_env.sv"
  `include "serial_ip_env_cfg.sv"

endpackage : serial_ip_env_pkg