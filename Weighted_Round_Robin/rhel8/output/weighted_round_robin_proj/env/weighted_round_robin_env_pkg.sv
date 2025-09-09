package weighted_round_robin_env_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import wrr_arbitration_agent_pkg::*;
    import wrr_prio_update_agent_pkg::*;
    import clk_rst_agent_pkg::*;
  `include "uvm_macros.svh"

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "weighted_round_robin_scoreboard.sv"
  `include "weighted_round_robin_env.sv"
  `include "weighted_round_robin_env_cfg.sv"

endpackage : weighted_round_robin_env_pkg