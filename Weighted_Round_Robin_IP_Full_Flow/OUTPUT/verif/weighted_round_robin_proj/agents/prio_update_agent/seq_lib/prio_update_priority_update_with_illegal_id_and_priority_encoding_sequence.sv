
class prio_update_priority_update_with_illegal_id_and_priority_encoding_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_priority_update_with_illegal_id_and_priority_encoding_sequence)

  // Knobs to structure updates across phases
  rand int unsigned pre_idle_cycles;        // idle before any update
  rand int unsigned legal_updates_cnt;      // number of directed legal updates (min/max)
  rand int unsigned illegal_attempt_cycles; // cycles to attempt "illegal" encodings (best effort)
  rand int unsigned illegal_update_pct;     // strobe percentage during illegal window
  rand int unsigned recovery_updates_cnt;   // legal updates after illegal attempts
  rand int unsigned gap_idle_min;           // min idle between updates
  rand int unsigned gap_idle_max;           // max idle between updates

  constraint c_knobs {
    pre_idle_cycles        inside {[6:12]};
    legal_updates_cnt      inside {[2:4]};
    illegal_attempt_cycles inside {[16:32]};
    illegal_update_pct     inside {[40:90]};  // aggressively assert prio_upt in illegal window
    recovery_updates_cnt   inside {[2:6]};
    gap_idle_min           inside {[1:3]};
    gap_idle_max           inside {[2:6]};
    gap_idle_max >= gap_idle_min;
  }

  function new(string name = "prio_update_priority_update_with_illegal_id_and_priority_encoding_sequence");
    super.new(name);
  endfunction

  // Drive one prio_update transaction with explicit values
  task drive_pu(logic [3:0] prio_v, logic [4:0] prio_id_v, bit prio_upt_v);
    prio_update_trans_item tr;
    tr = prio_update_trans_item::type_id::create("pu_tr",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { prio == prio_v; prio_id == prio_id_v; prio_upt == prio_upt_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(tr);
  endtask

  // Idle one cycle (no update)
  task idle_cycle();
    drive_pu(4'h0, 5'd0, 1'b0);
  endtask

  // Idle for N cycles
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) idle_cycle();
  endtask

  // Random legal update
  task legal_update_once();
    logic [3:0] pr_v;
    logic [4:0] id_v;
    void'(std::randomize(pr_v) with { pr_v inside {[0:15]}; });
    void'(std::randomize(id_v) with { id_v inside {[0:31]}; });
    drive_pu(pr_v, id_v, 1'b1);
  endtask

  // Attempt "illegal" update:
  // Note: With ID_BITS=5 for N=32 and PRIORITY_W=4, true out-of-range values cannot be represented.
  // We still aggressively toggle prio_upt with randomized values to ensure DUT stability and scoreboard checks.
  task attempt_illegal_like_once();
    logic [3:0] pr_v;
    logic [4:0] id_v;
    bit choose_corner;
    // Corners: min/max legal values to bracket behavior; scoreboard must remain stable
    void'(std::randomize(choose_corner));
    if (choose_corner) begin
      pr_v = ($urandom_range(0,1) ? 4'h0 : 4'hF);
      id_v = ($urandom_range(0,1) ? 5'd0 : 5'd31);
    end
    else begin
      void'(std::randomize(pr_v) with { pr_v inside {[0:15]}; });
      void'(std::randomize(id_v) with { id_v inside {[0:31]}; });
    end
    // Strobe asserted to attempt update
    drive_pu(pr_v, id_v, 1'b1);
  endtask

  virtual task body();
    int unsigned i;
    int unsigned gap;
    int unsigned pre_cfg, illeg_win_cfg, rec_cfg, tail_cfg;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update knobs")
    end

    // Optionally align with rr_request timing (if provided)
    if (uvm_config_db#(int)::get(null, "*", "pre_idle_cycles", pre_cfg))          pre_idle_cycles        = pre_cfg;
    if (uvm_config_db#(int)::get(null, "*", "illegal_window_cycles", illeg_win_cfg)) illegal_attempt_cycles = illeg_win_cfg;
    if (uvm_config_db#(int)::get(null, "*", "recovery_cycles", rec_cfg))         recovery_updates_cnt   = (rec_cfg > 2) ? (rec_cfg/2) : recovery_updates_cnt;
    if (uvm_config_db#(int)::get(null, "*", "tail_idle_cycles", tail_cfg))       gap_idle_max           = (tail_cfg > gap_idle_max) ? tail_cfg : gap_idle_max;

    // Phase-1: Pre-idle
    idle_n(pre_idle_cycles);

    // Phase-2: Directed legal updates (min/max and randomized)
    // Ensure coverage of min (prio=0, id=0) and max (prio=F, id=31)
    drive_pu(4'h0, 5'd0, 1'b1);
    repeat ($urandom_range(1, legal_updates_cnt)) begin
      legal_update_once();
      void'(std::randomize(gap) with { gap inside {[gap_idle_min:gap_idle_max]}; });
      idle_n(gap);
    end
    drive_pu(4'hF, 5'd31, 1'b1);

    // Phase-3: Aggressive "illegal-like" update window:
    // Even though out-of-range cannot be encoded with current widths, we assert many updates to ensure stability.
    for (i = 0; i < illegal_attempt_cycles; i++) begin
      bit do_upt = ($urandom_range(0,99) < illegal_update_pct);
      if (do_upt) begin
        attempt_illegal_like_once();
      end
      else begin
        idle_cycle();
      end
    end

    // Phase-4: Recovery with clean legal updates
    repeat (recovery_updates_cnt) begin
      legal_update_once();
      void'(std::randomize(gap) with { gap inside {[gap_idle_min:gap_idle_max]}; });
      idle_n(gap);
    end

    // Tail: a few idle cycles
    idle_n($urandom_range(4,8));
  endtask
endclass