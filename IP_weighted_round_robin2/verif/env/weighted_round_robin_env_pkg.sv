package weighted_round_robin_env_pkg;

    //******************************************************************************
    // Imports
    //******************************************************************************
    import uvm_pkg::*;
    import requestor_agent_pkg::*;
    import prio_update_agent_pkg::*;
    import clk_rst_agent_pkg::*;

    //******************************************************************************
    // Includes
    //******************************************************************************
    `include "weighted_round_robin_ref_model.sv"
    `include "weighted_round_robin_scoreboard.sv"
    `include "weighted_round_robin_env.sv"
    `include "weighted_round_robin_env_cfg.sv"

endpackage : weighted_round_robin_env_pkg
