

















package rr_grant_monitor_seq_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import rr_grant_monitor_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "rr_grant_monitor_base_seq.sv"
  // Provide alias to satisfy sequences extending rr_grant_monitor_base_seq
  typedef rr_grant_monitor_base_sequence rr_grant_monitor_base_seq;

  `include "rr_grant_monitor_basic_synchronous_reset_initialization_test_sequence.sv"
  `include "rr_grant_monitor_basic_arbitration_grant_and_latency_test_sequence.sv"
  `include "rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence.sv"
  `include "rr_grant_monitor_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence.sv"
  `include "rr_grant_monitor_illegal_req_encoding_combined_test_sequence.sv"
  `include "rr_grant_monitor_simultaneous_priority_update_and_ack_sequence.sv"
  `include "rr_grant_monitor_priority_update_attempted_during_reset_sequence.sv"
  `include "rr_grant_monitor_priority_update_with_illegal_id_and_priority_encoding_sequence.sv"
  `include "rr_grant_monitor_reset_deasserted_mid_cycle_sequence.sv"
  `include "rr_grant_monitor_grant_output_boundary_requestor_id_and_one_hot_test_sequence.sv"
  `include "rr_grant_monitor_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence.sv"
  `include "rr_grant_monitor_grant_output_stability_under_reset_and_immediate_request_test_sequence.sv"
  `include "rr_grant_monitor_synchronous_reset_min_max_req_corner_case_sequence.sv"
  `include "rr_grant_monitor_synchronous_reset_with_priority_update_edge_case_sequence.sv"
  `include "rr_grant_monitor_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence.sv"
  `include "rr_grant_monitor_minimum_and_maximum_priority_update_corner_case_combined_sequence.sv"
  `include "rr_grant_monitor_priority_update_during_credit_refill_corner_case_sequence.sv"

endpackage : rr_grant_monitor_seq_pkg