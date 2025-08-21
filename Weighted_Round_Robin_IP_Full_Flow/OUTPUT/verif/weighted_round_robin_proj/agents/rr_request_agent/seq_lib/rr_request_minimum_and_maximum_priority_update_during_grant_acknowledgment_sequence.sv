
class rr_request_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence)

  // Constrained-random knobs to shape timing and pacing
  rand int unsigned pre_idle_cycles;     // initial idle cycles after reset
  rand int unsigned hold_len;            // cycles to hold a single one-hot requestor
  rand int unsigned id_gap_cycles;       // optional idle gap between IDs
  rand int unsigned pass_gap_cycles;     // idle gap between the two passes (min then max)

  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    hold_len        inside {[2:3]};      // at least 2 cycles so we can place ack on a known cycle
    id_gap_cycles   inside {[0:2]};
    pass_gap_cycles inside {[1:4]};
  }

  // Share knobs with prio_update seq to align ack with prio_upt
  string CFG_PRE_IDLE   = "mmap_pre_idle_cycles";
  string CFG_HOLD_LEN   = "mmap_hold_len";
  string CFG_ID_GAP     = "mmap_id_gap_cycles";
  string CFG_PASS_GAP   = "mmap_pass_gap_cycles";

  function new(string name = "rr_request_minimum_and_maximum_priority_update_during_grant_acknowledgment_sequence");
    super.new(name);
  endfunction

  // Drive exactly one cycle via CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item (drive_cycle)")
    end
    finish_item(tr);
  endtask

  // Idle N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    for (int unsigned i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Hold one-hot for 'hold_len' cycles; assert ack only on the last cycle to coincide with prio_upt
  task hold_onehot_ack(int unsigned id);
    logic [31:0] mask;
    mask = (32'h1 << id[4:0]);
    for (int unsigned i = 0; i < hold_len; i++) begin
      bit ack_v = (i == (hold_len-1));
      drive_cycle(mask, ack_v);
    end
  endtask

  virtual task body();
    // Attempt to pick up shared configuration, otherwise randomize and publish
    int tmp;
    bit got = 0;

    // Try to fetch pre-agreed knobs
    got |= uvm_config_db#(int)::get(null, "*", CFG_PRE_IDLE, tmp);      if (got) pre_idle_cycles = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_HOLD_LEN, tmp);      if (got) hold_len        = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_ID_GAP, tmp);        if (got) id_gap_cycles   = tmp;
    got |= uvm_config_db#(int)::get(null, "*", CFG_PASS_GAP, tmp);      if (got) pass_gap_cycles = tmp;

    // If not all were provided, randomize then publish for the partner sequence to consume
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize request sequence knobs")
    end
    // Publish chosen knobs (idempotent)
    uvm_config_db#(int)::set(null, "*", CFG_PRE_IDLE,   pre_idle_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_HOLD_LEN,   hold_len);
    uvm_config_db#(int)::set(null, "*", CFG_ID_GAP,     id_gap_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_PASS_GAP,   pass_gap_cycles);

    // Pre-idle
    idle_n(pre_idle_cycles);

    // Pass 1: For each requestor ID, single one-hot window; assert ack on the last cycle.
    // The prio_update sequence will set that ID's priority to MIN (0) coincident with this ack.
    for (int unsigned id = 0; id < 32; id++) begin
      hold_onehot_ack(id);
      idle_n(id_gap_cycles);
    end

    // Idle gap between passes
    idle_n(pass_gap_cycles);

    // Pass 2: Repeat sweep. The prio_update sequence will set that ID's priority to MAX (15).
    for (int unsigned id = 0; id < 32; id++) begin
      hold_onehot_ack(id);
      idle_n(id_gap_cycles);
    end

    // Tail idle to allow monitor/scoreboard to observe post-update grants
    idle_n($urandom_range(4,8));
  endtask
endclass