package weighted_round_robin_test_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import weighted_round_robin_env_pkg::*;
  `include "uvm_macros.svh"
  import wrr_arbitration_seq_pkg::*;
  import wrr_prio_update_seq_pkg::*;
  import clk_rst_seq_pkg::*;
  import wrr_arbitration_agent_pkg::*;
  import wrr_prio_update_agent_pkg::*;
  import clk_rst_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "weighted_round_robin_base_test.sv"
  `include "weighted_round_robin_mid_sim_rst_test.sv"

endpackage : weighted_round_robin_test_pkg