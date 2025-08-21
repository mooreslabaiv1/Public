
class prio_update_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence)

  // Constrained-random knobs; must stay aligned with rr_request sequence
  rand int unsigned pre_idle_cycles;
  rand int unsigned hold_len;          // cycles per ID window; prio_upt asserted on last cycle
  rand int unsigned id_gap_cycles;
  rand int unsigned pass_gap_cycles;

  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    hold_len        inside {[2:3]};
    id_gap_cycles   inside {[0:2]};
    pass_gap_cycles inside {[1:4]};
  }

  // Shared keys with rr_request to lock timing relationship
  string CFG_PRE_IDLE   = "mmap_pre_idle_cycles";
  string CFG_HOLD_LEN   = "mmap_hold_len";
  string CFG_ID_GAP     = "mmap_id_gap_cycles";
  string CFG_PASS_GAP   = "mmap_pass_gap_cycles";

  function new(string name = "prio_update_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence");
    super.new(name);
  endfunction

  // Drive one prio_update cycle
  task drive_pu_cycle(logic [3:0] pr_v, logic [4:0] id_v, bit strobe);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == pr_v; prio_id == id_v; prio_upt == strobe; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Idle N cycles (no update)
  task idle_n(int unsigned n);
    for (int unsigned i = 0; i < n; i++) begin
      drive_pu_cycle(4'h0, 5'd0, 1'b0);
    end
  endtask

  // For a given ID, hold_len cycles: strobe only on the last cycle
  task program_id_once(int unsigned id, logic [3:0] prio_val);
    for (int unsigned i = 0; i < hold_len; i++) begin
      bit st = (i == (hold_len-1));
      if (st) drive_pu_cycle(prio_val, id[4:0], 1'b1);
      else    drive_pu_cycle(4'h0, 5'd0, 1'b0);
    end
  endtask

  virtual task body();
    // Attempt to fetch shared knobs set by rr_request; otherwise randomize and publish
    int tmp;
    bit got = 0;

    got |= uvm_config_db#(int)::get(null, "*", CFG_PRE_IDLE, tmp);   if (got) pre_idle_cycles = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_HOLD_LEN, tmp);   if (got) hold_len        = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_ID_GAP, tmp);     if (got) id_gap_cycles   = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_PASS_GAP, tmp);   if (got) pass_gap_cycles = tmp;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Publish (idempotent) to ensure alignment if we were first
    uvm_config_db#(int)::set(null, "*", CFG_PRE_IDLE,   pre_idle_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_HOLD_LEN,   hold_len);
    uvm_config_db#(int)::set(null, "*", CFG_ID_GAP,     id_gap_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_PASS_GAP,   pass_gap_cycles);

    // Pre-idle
    idle_n(pre_idle_cycles);

    // Pass 1: set each requestor's priority to MIN (0) coincident with ack=1 from rr_request
    for (int unsigned id = 0; id < 32; id++) begin
      program_id_once(id, 4'h0);
      idle_n(id_gap_cycles);
    end

    // Gap between passes
    idle_n(pass_gap_cycles);

    // Pass 2: set each requestor's priority to MAX (15) coincident with ack
    for (int unsigned id = 0; id < 32; id++) begin
      program_id_once(id, 4'hF);
      idle_n(id_gap_cycles);
    end

    // Tail idle
    idle_n($urandom_range(4,8));
  endtask
endclass