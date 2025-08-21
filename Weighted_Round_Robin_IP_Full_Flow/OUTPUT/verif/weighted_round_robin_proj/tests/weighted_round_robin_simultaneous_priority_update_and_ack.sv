

class weighted_round_robin_simultaneous_priority_update_and_ack_test extends weighted_round_robin_base_test;

  `uvm_component_utils(weighted_round_robin_simultaneous_priority_update_and_ack_test)

  function new(string name="weighted_round_robin_simultaneous_priority_update_and_ack_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Declarations at the beginning of the task as per coding guidelines
    rr_request_simultaneous_priority_update_and_ack_sequence        m_rr_request_simultaneous_priority_update_and_ack_seq;
    rr_grant_monitor_simultaneous_priority_update_and_ack_sequence  m_rr_grant_monitor_simultaneous_priority_update_and_ack_seq;
    prio_update_simultaneous_priority_update_and_ack_sequence       m_prio_update_simultaneous_priority_update_and_ack_seq;
    int pre_idle_cycles;
    int burst_len;
    int gap_cycles;
    int tail_cycles;
    int evt0_idx;
    int evt1_idx;
    int evt0_id;
    int evt1_id;
    int evt0_prio;
    int evt1_prio;

    super.run_phase(phase);
    phase.raise_objection(this);

    // Create sequences before fork (no declarations inside fork-join)
    m_rr_request_simultaneous_priority_update_and_ack_seq =
      rr_request_simultaneous_priority_update_and_ack_sequence::type_id::create("m_rr_request_simultaneous_priority_update_and_ack_seq");
    m_rr_grant_monitor_simultaneous_priority_update_and_ack_seq =
      rr_grant_monitor_simultaneous_priority_update_and_ack_sequence::type_id::create("m_rr_grant_monitor_simultaneous_priority_update_and_ack_seq");
    m_prio_update_simultaneous_priority_update_and_ack_seq =
      prio_update_simultaneous_priority_update_and_ack_sequence::type_id::create("m_prio_update_simultaneous_priority_update_and_ack_seq");

    // Program shared configuration to align simultaneous ack and prio_upt on two events (min/max)
    begin
      // Constrained-random selection with bias toward inner indices
      void'(std::randomize(pre_idle_cycles) with { pre_idle_cycles inside {[6:12]}; });
      void'(std::randomize(burst_len)       with { burst_len inside {[4:8]}; });
      void'(std::randomize(gap_cycles)      with { gap_cycles inside {[2:6]}; });
      void'(std::randomize(tail_cycles)     with { tail_cycles inside {[5:12]}; });
      void'(std::randomize(evt0_idx)        with { evt0_idx inside {[0:3]}; });
      void'(std::randomize(evt1_idx)        with { evt1_idx inside {[1:4]}; });

      if (evt0_idx >= burst_len) evt0_idx = burst_len-1;
      if (evt1_idx >= burst_len) evt1_idx = (burst_len>1) ? burst_len-2 : 0;

      // Deterministic edges to hit coverage
      evt0_id   = 0;   // min ID
      evt1_id   = 31;  // max ID
      evt0_prio = 0;   // min priority
      evt1_prio = 15;  // max priority

      // Publish to both sequences
      uvm_config_db#(int)::set(this, "*", "pre_idle_cycles", pre_idle_cycles);
      uvm_config_db#(int)::set(this, "*", "burst_len",       burst_len);
      uvm_config_db#(int)::set(this, "*", "gap_cycles",      gap_cycles);
      uvm_config_db#(int)::set(this, "*", "tail_cycles",     tail_cycles);
      uvm_config_db#(int)::set(this, "*", "evt0_idx",        evt0_idx);
      uvm_config_db#(int)::set(this, "*", "evt1_idx",        evt1_idx);
      uvm_config_db#(int)::set(this, "*", "evt0_id",         evt0_id);
      uvm_config_db#(int)::set(this, "*", "evt1_id",         evt1_id);
      uvm_config_db#(int)::set(this, "*", "evt0_prio",       evt0_prio);
      uvm_config_db#(int)::set(this, "*", "evt1_prio",       evt1_prio);
    end

    fork
      // Start the rr_request sequence
      m_rr_request_simultaneous_priority_update_and_ack_seq.start(m_env.m_rr_request_agent.m_seqr);
      // Start the rr_grant_monitor sequence
      m_rr_grant_monitor_simultaneous_priority_update_and_ack_seq.start(m_env.m_rr_grant_monitor_agent.m_seqr);
      // Start the prio_update sequence
      m_prio_update_simultaneous_priority_update_and_ack_seq.start(m_env.m_prio_update_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask

endclass : weighted_round_robin_simultaneous_priority_update_and_ack_test