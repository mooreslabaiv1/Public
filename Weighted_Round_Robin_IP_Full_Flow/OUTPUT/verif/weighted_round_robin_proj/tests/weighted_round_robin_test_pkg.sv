
















package weighted_round_robin_test_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import weighted_round_robin_env_pkg::*;
  import rr_request_seq_pkg::*;
  import rr_grant_monitor_seq_pkg::*;
  import prio_update_seq_pkg::*;
  import clk_rst_seq_pkg::*;
  import rr_request_agent_pkg::*;
  import rr_grant_monitor_agent_pkg::*;
  import prio_update_agent_pkg::*;
  import clk_rst_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "weighted_round_robin_base_test.sv"
  `include "weighted_round_robin_mid_sim_rst_test.sv"
  `include "weighted_round_robin_basic_synchronous_reset_initialization_test.sv"
  `include "weighted_round_robin_basic_arbitration_grant_and_latency_test.sv"
  `include "weighted_round_robin_synchronous_reset_stress_with_back_to_back_requests.sv"
  `include "weighted_round_robin_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test.sv"
  `include "weighted_round_robin_illegal_req_encoding_combined_test.sv"
  `include "weighted_round_robin_simultaneous_priority_update_and_ack.sv"
  `include "weighted_round_robin_priority_update_attempted_during_reset.sv"
  `include "weighted_round_robin_priority_update_with_illegal_id_and_priority_encoding.sv"
  `include "weighted_round_robin_reset_deasserted_mid_cycle.sv"
  `include "weighted_round_robin_grant_output_boundary_requestor_id_and_one_hot_test.sv"
  `include "weighted_round_robin_arbiter_no_requestors_and_post_empty_grant_behavior_test.sv"
  `include "weighted_round_robin_grant_output_stability_under_reset_and_immediate_request_test.sv"
  `include "weighted_round_robin_synchronous_reset_min_max_req_corner_case.sv"
  `include "weighted_round_robin_synchronous_reset_with_priority_update_edge_case.sv"
  `include "weighted_round_robin_minimum_and_maximum_priority_update_corner_case_combined.sv"
  `include "weighted_round_robin_minimum_and_maximum_priority_update_during_grant_acknowledgment.sv"
  `include "weighted_round_robin_priority_update_during_credit_refill_corner_case.sv"

endpackage : weighted_round_robin_test_pkg