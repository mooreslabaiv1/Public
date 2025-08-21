package weighted_round_robin_env_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import rr_request_agent_pkg::*;
    import rr_grant_monitor_agent_pkg::*;
    import prio_update_agent_pkg::*;
    import clk_rst_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "weighted_round_robin_scoreboard.sv"
  `include "weighted_round_robin_env.sv"
  `include "weighted_round_robin_env_cfg.sv"

endpackage : weighted_round_robin_env_pkg