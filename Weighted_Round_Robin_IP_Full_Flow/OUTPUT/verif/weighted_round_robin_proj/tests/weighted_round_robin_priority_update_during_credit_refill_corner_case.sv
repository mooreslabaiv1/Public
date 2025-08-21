


class weighted_round_robin_priority_update_during_credit_refill_corner_case_test extends weighted_round_robin_base_test;

  `uvm_component_utils(weighted_round_robin_priority_update_during_credit_refill_corner_case_test)

  function new(string name="weighted_round_robin_priority_update_during_credit_refill_corner_case_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    rr_request_seq_pkg::rr_request_priority_update_during_credit_refill_corner_case_sequence        m_rr_request_priority_update_during_credit_refill_corner_case_seq;
    rr_grant_monitor_seq_pkg::rr_grant_monitor_priority_update_during_credit_refill_corner_case_sequence  m_rr_grant_monitor_priority_update_during_credit_refill_corner_case_seq;
    prio_update_seq_pkg::prio_update_priority_update_during_credit_refill_corner_case_sequence       m_prio_update_priority_update_during_credit_refill_corner_case_seq;

    super.run_phase(phase);
    phase.raise_objection(this);

    // Create sequences before forking (per block-scope declaration guidelines)
    m_rr_request_priority_update_during_credit_refill_corner_case_seq =
      rr_request_seq_pkg::rr_request_priority_update_during_credit_refill_corner_case_sequence::type_id::create("m_rr_request_priority_update_during_credit_refill_corner_case_seq");
    m_rr_grant_monitor_priority_update_during_credit_refill_corner_case_seq =
      rr_grant_monitor_seq_pkg::rr_grant_monitor_priority_update_during_credit_refill_corner_case_sequence::type_id::create("m_rr_grant_monitor_priority_update_during_credit_refill_corner_case_seq");
    m_prio_update_priority_update_during_credit_refill_corner_case_seq =
      prio_update_seq_pkg::prio_update_priority_update_during_credit_refill_corner_case_sequence::type_id::create("m_prio_update_priority_update_during_credit_refill_corner_case_seq");

    fork
      m_rr_request_priority_update_during_credit_refill_corner_case_seq.start(m_env.m_rr_request_agent.m_seqr);
      m_rr_grant_monitor_priority_update_during_credit_refill_corner_case_seq.start(m_env.m_rr_grant_monitor_agent.m_seqr);
      m_prio_update_priority_update_during_credit_refill_corner_case_seq.start(m_env.m_prio_update_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask

endclass : weighted_round_robin_priority_update_during_credit_refill_corner_case_test