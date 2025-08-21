

class rr_request_simultaneous_priority_update_and_ack_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_simultaneous_priority_update_and_ack_sequence)

  // Constrained-random knobs to shape timing of the event windows
  rand int unsigned pre_idle_cycles;   // idle cycles after reset before driving
  rand int unsigned burst_len;         // length of one-hot burst window per event
  rand int unsigned gap_cycles;        // gap between two windows
  rand int unsigned tail_cycles;       // idle cycles after the two windows
  rand int unsigned evt0_idx;          // cycle index within first burst to assert ack
  rand int unsigned evt1_idx;          // cycle index within second burst to assert ack

  // Constraints
  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    burst_len       inside {[4:8]};
    gap_cycles      inside {[2:6]};
    tail_cycles     inside {[5:12]};
    evt0_idx        inside {[0:7]}; // further limited at runtime by burst_len
    evt1_idx        inside {[0:7]};
  }

  // Configuration values shared across agents via uvm_config_db
  int evt0_id, evt1_id;
  int evt0_prio, evt1_prio; // not used here but carried for symmetry with prio_update seq

  function new(string name = "rr_request_simultaneous_priority_update_and_ack_sequence");
    super.new(name);
  endfunction

  // Helper to drive one cycle
  task drive_req_ack(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Idle N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_req_ack(32'h0000_0000, 1'b0);
    end
  endtask

  // One-hot burst for a selected id; assert ack only at sel_idx
  task do_burst(int unsigned id, int unsigned len, int unsigned sel_idx);
    int unsigned i;
    logic [31:0] mask;
    mask = (32'h1 << id[4:0]);
    for (i = 0; i < len; i++) begin
      drive_req_ack(mask, (i == sel_idx));
    end
  endtask

  virtual task body();
    // Attempt to fetch shared configuration; if not present, randomize and publish it.
    int got;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize top-level timing knobs")
    end

    // Limit event indices to burst_len
    if (evt0_idx >= burst_len) evt0_idx = burst_len-1;
    if (evt1_idx >= burst_len) evt1_idx = burst_len-1;

    // Get or set evt0_id/evt1_id and prio hints
    got = 0;
    got |= uvm_config_db#(int)::get(null, "*", "evt0_id", evt0_id);
    got |= uvm_config_db#(int)::get(null, "*", "evt1_id", evt1_id);
    got |= uvm_config_db#(int)::get(null, "*", "evt0_prio", evt0_prio);
    got |= uvm_config_db#(int)::get(null, "*", "evt1_prio", evt1_prio);
    void'(uvm_config_db#(int)::get(null, "*", "pre_idle_cycles", pre_idle_cycles));
    void'(uvm_config_db#(int)::get(null, "*", "burst_len", burst_len));
    void'(uvm_config_db#(int)::get(null, "*", "gap_cycles", gap_cycles));
    void'(uvm_config_db#(int)::get(null, "*", "tail_cycles", tail_cycles));
    void'(uvm_config_db#(int)::get(null, "*", "evt0_idx", evt0_idx));
    void'(uvm_config_db#(int)::get(null, "*", "evt1_idx", evt1_idx));

    if (!got) begin
      // Default directed choices to hit min/max bins deterministically
      evt0_id   = 0;   // min id
      evt1_id   = 31;  // max id
      evt0_prio = 0;   // min priority (hint for prio_update agent)
      evt1_prio = 15;  // max priority (hint for prio_update agent)

      // Publish so prio_update sequence can align
      uvm_config_db#(int)::set(null, "*", "evt0_id", evt0_id);
      uvm_config_db#(int)::set(null, "*", "evt1_id", evt1_id);
      uvm_config_db#(int)::set(null, "*", "evt0_prio", evt0_prio);
      uvm_config_db#(int)::set(null, "*", "evt1_prio", evt1_prio);
      uvm_config_db#(int)::set(null, "*", "pre_idle_cycles", pre_idle_cycles);
      uvm_config_db#(int)::set(null, "*", "burst_len", burst_len);
      uvm_config_db#(int)::set(null, "*", "gap_cycles", gap_cycles);
      uvm_config_db#(int)::set(null, "*", "tail_cycles", tail_cycles);
      uvm_config_db#(int)::set(null, "*", "evt0_idx", evt0_idx);
      uvm_config_db#(int)::set(null, "*", "evt1_idx", evt1_idx);
    end

    // Phase 1: Pre-idle
    idle_n(pre_idle_cycles);

    // Phase 2: First window — drive one-hot on evt0_id; assert ack at evt0_idx
    do_burst(evt0_id, burst_len, evt0_idx);

    // Gap
    idle_n(gap_cycles);

    // Phase 3: Second window — drive one-hot on evt1_id; assert ack at evt1_idx
    do_burst(evt1_id, burst_len, evt1_idx);

    // Tail idle
    idle_n(tail_cycles);
  endtask
endclass