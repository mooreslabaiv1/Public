

class prio_update_simultaneous_priority_update_and_ack_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_simultaneous_priority_update_and_ack_sequence)

  // Constrained-random knobs mirroring the rr_request sequence to maintain cycle alignment
  rand int unsigned pre_idle_cycles;
  rand int unsigned burst_len;
  rand int unsigned gap_cycles;
  rand int unsigned tail_cycles;
  rand int unsigned evt0_idx;
  rand int unsigned evt1_idx;

  // Directed IDs/priorities for two events
  int evt0_id, evt1_id;
  int evt0_prio, evt1_prio;

  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    burst_len       inside {[4:8]};
    gap_cycles      inside {[2:6]};
    tail_cycles     inside {[5:12]};
    evt0_idx        inside {[0:7]};
    evt1_idx        inside {[0:7]};
  }

  function new(string name = "prio_update_simultaneous_priority_update_and_ack_sequence");
    super.new(name);
  endfunction

  // Drive one cycle on priority interface
  task drive_pu_cycle(logic [3:0] prio_v, logic [4:0] prio_id_v, logic prio_upt_v);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with {
          prio     == prio_v;
          prio_id  == prio_id_v;
          prio_upt == prio_upt_v;
        }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Idle for N cycles (prio_upt=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_pu_cycle(4'h0, 5'd0, 1'b0);
    end
  endtask

  // Burst window; assert prio_upt for one cycle at idx with provided id/prio
  task do_burst(int unsigned id, int unsigned len, int unsigned sel_idx, int unsigned pr_val);
    int unsigned i;
    for (i = 0; i < len; i++) begin
      if (i == sel_idx) begin
        drive_pu_cycle(pr_val[3:0], id[4:0], 1'b1);
      end
      else begin
        drive_pu_cycle(4'h0, 5'd0, 1'b0);
      end
    end
  endtask

  virtual task body();
    int got;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update timing knobs")
    end

    // Attempt to fetch shared configuration from uvm_config_db
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
      // Default to min/max directed values to hit coverage bins if test didn't set them
      evt0_id   = 0;   evt1_id   = 31;
      evt0_prio = 0;   evt1_prio = 15;
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

    // Ensure selected indices are within burst_len
    if (evt0_idx >= burst_len) evt0_idx = burst_len-1;
    if (evt1_idx >= burst_len) evt1_idx = burst_len-1;

    // Pre-idle
    idle_n(pre_idle_cycles);

    // First window: prio update coincident with ack in the other agent
    do_burst(evt0_id, burst_len, evt0_idx, evt0_prio);

    // Gap
    idle_n(gap_cycles);

    // Second window: max edges
    do_burst(evt1_id, burst_len, evt1_idx, evt1_prio);

    // Tail idle
    idle_n(tail_cycles);
  endtask
endclass