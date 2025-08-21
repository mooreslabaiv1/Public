

class weighted_round_robin_synchronous_reset_stress_with_back_to_back_requests_test extends weighted_round_robin_base_test;

  `uvm_component_utils(weighted_round_robin_synchronous_reset_stress_with_back_to_back_requests_test)

  function new(string name="weighted_round_robin_synchronous_reset_stress_with_back_to_back_requests_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence m_rr_request_synchronous_reset_stress_with_back_to_back_requests_seq;
    rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence m_rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_seq;
    prio_update_synchronous_reset_stress_with_back_to_back_requests_sequence m_prio_update_synchronous_reset_stress_with_back_to_back_requests_seq;

    super.run_phase(phase);
    phase.raise_objection(this);

    // Create sequences prior to fork per coding guidelines
    m_rr_request_synchronous_reset_stress_with_back_to_back_requests_seq = rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence::type_id::create("m_rr_request_synchronous_reset_stress_with_back_to_back_requests_seq");
    m_rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_seq = rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence::type_id::create("m_rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_seq");
    m_prio_update_synchronous_reset_stress_with_back_to_back_requests_seq = prio_update_synchronous_reset_stress_with_back_to_back_requests_sequence::type_id::create("m_prio_update_synchronous_reset_stress_with_back_to_back_requests_seq");

    fork
      // Start the rr_request sequence
      m_rr_request_synchronous_reset_stress_with_back_to_back_requests_seq.start(m_env.m_rr_request_agent.m_seqr);
      // Start the rr_grant_monitor sequence
      m_rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_seq.start(m_env.m_rr_grant_monitor_agent.m_seqr);
      // Start the prio_update sequence
      m_prio_update_synchronous_reset_stress_with_back_to_back_requests_seq.start(m_env.m_prio_update_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask

endclass : weighted_round_robin_synchronous_reset_stress_with_back_to_back_requests_test