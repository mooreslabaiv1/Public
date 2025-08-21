

















package rr_request_seq_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import rr_request_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "rr_request_base_seq.sv"
  // Provide alias to satisfy sequences extending rr_request_base_seq
  typedef rr_request_base_sequence rr_request_base_seq;

  `include "rr_request_basic_synchronous_reset_initialization_test_sequence.sv"
  `include "rr_request_basic_arbitration_grant_and_latency_test_sequence.sv"
  `include "rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence.sv"
  `include "rr_request_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence.sv"
  `include "rr_request_illegal_req_encoding_combined_test_sequence.sv"
  `include "rr_request_simultaneous_priority_update_and_ack_sequence.sv"
  `include "rr_request_priority_update_attempted_during_reset_sequence.sv"
  `include "rr_request_priority_update_with_illegal_id_and_priority_encoding_sequence.sv"
  `include "rr_request_reset_deasserted_mid_cycle_sequence.sv"
  `include "rr_request_priority_update_during_credit_refill_corner_case_sequence.sv"
  `include "rr_request_grant_output_stability_under_reset_and_immediate_request_test_sequence.sv"
  `include "rr_request_grant_output_boundary_requestor_id_and_one_hot_test_sequence.sv"
  `include "rr_request_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence.sv"
  `include "rr_request_synchronous_reset_min_max_req_corner_case_sequence.sv"
  `include "rr_request_synchronous_reset_with_priority_update_edge_case_sequence.sv"
  `include "rr_request_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence.sv"
  `include "rr_request_minimum_and_maximum_priority_update_corner_case_combined_sequence.sv"

endpackage : rr_request_seq_pkg