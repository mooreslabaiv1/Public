package weighted_round_robin_test_pkg;

    //******************************************************************************
    // Imports
    //******************************************************************************
    import uvm_pkg::*;
    import weighted_round_robin_env_pkg::*;
    import requestor_seq_pkg::*;
    import prio_update_seq_pkg::*;
    import clk_rst_seq_pkg::*;
    import requestor_agent_pkg::*;
    import prio_update_agent_pkg::*;
    import clk_rst_agent_pkg::*;

    //******************************************************************************
    // Includes
    //******************************************************************************
    `include "weighted_round_robin_base_test.sv"
    `include "weighted_round_robin_mid_sim_rst_test.sv"
    `include "weighted_round_robin_basic_functionality_test.sv"

endpackage : weighted_round_robin_test_pkg
