

class weighted_round_robin_synchronous_reset_min_max_req_corner_case_test extends weighted_round_robin_base_test;

  `uvm_component_utils(weighted_round_robin_synchronous_reset_min_max_req_corner_case_test)

  function new(string name="weighted_round_robin_synchronous_reset_min_max_req_corner_case_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Declarations at the beginning of the task (per guidelines)
    rr_request_synchronous_reset_min_max_req_corner_case_sequence m_rr_request_synchronous_reset_min_max_req_corner_case_seq;
    rr_grant_monitor_synchronous_reset_min_max_req_corner_case_sequence m_rr_grant_monitor_synchronous_reset_min_max_req_corner_case_seq;
    prio_update_synchronous_reset_min_max_req_corner_case_sequence m_prio_update_synchronous_reset_min_max_req_corner_case_seq;

    super.run_phase(phase);
    phase.raise_objection(this);

    // Create sequences prior to fork as required by coding guidelines
    m_rr_request_synchronous_reset_min_max_req_corner_case_seq =
      rr_request_synchronous_reset_min_max_req_corner_case_sequence::type_id::create("m_rr_request_synchronous_reset_min_max_req_corner_case_seq");
    m_rr_grant_monitor_synchronous_reset_min_max_req_corner_case_seq =
      rr_grant_monitor_synchronous_reset_min_max_req_corner_case_sequence::type_id::create("m_rr_grant_monitor_synchronous_reset_min_max_req_corner_case_seq");
    m_prio_update_synchronous_reset_min_max_req_corner_case_seq =
      prio_update_synchronous_reset_min_max_req_corner_case_sequence::type_id::create("m_prio_update_synchronous_reset_min_max_req_corner_case_seq");

    fork
      // Start the rr_request sequence
      m_rr_request_synchronous_reset_min_max_req_corner_case_seq.start(m_env.m_rr_request_agent.m_seqr);
      // Start the rr_grant_monitor sequence
      m_rr_grant_monitor_synchronous_reset_min_max_req_corner_case_seq.start(m_env.m_rr_grant_monitor_agent.m_seqr);
      // Start the prio_update sequence
      m_prio_update_synchronous_reset_min_max_req_corner_case_seq.start(m_env.m_prio_update_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask

endclass : weighted_round_robin_synchronous_reset_min_max_req_corner_case_test