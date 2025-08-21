
class prio_update_priority_update_attempted_during_reset_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_priority_update_attempted_during_reset_sequence)

  // Knobs controlling "attempts during reset" and post-reset legal updates
  rand int unsigned reset_attempts_min;   // lower bound for attempts during reset window
  rand int unsigned reset_attempts_max;   // upper bound for attempts during reset window
  rand int unsigned post_reset_gap;       // idle cycles after reset before legal updates
  rand int unsigned legal_updates_cnt;    // number of legal priority updates after reset
  rand int unsigned repeat_blocks;        // repeat pattern of reset-attempts + legal-updates

  constraint c_knobs {
    reset_attempts_min inside {[3:5]};
    reset_attempts_max inside {[6:10]};
    reset_attempts_max >= reset_attempts_min;
    post_reset_gap      inside {[2:6]};
    legal_updates_cnt   inside {[2:6]};
    repeat_blocks       inside {[1:3]};
  }

  function new(string name = "prio_update_priority_update_attempted_during_reset_sequence");
    super.new(name);
  endfunction

  // Drive one prio_update transaction
  task drive_update(logic [3:0] prio_v, logic [4:0] id_v, bit upt);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == prio_v; prio_id == id_v; prio_upt == upt; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Attempt an update with min id/prio
  task attempt_min_update(bit upt);
    drive_update(4'h0, 5'd0, upt);
  endtask

  // Attempt an update with max id/prio
  task attempt_max_update(bit upt);
    drive_update(4'hF, 5'd31, upt);
  endtask

  // Attempt an update with randomized legal values
  task attempt_random_update(bit upt);
    logic [3:0] pr;
    logic [4:0] id;
    void'(std::randomize(pr)  with { pr  inside {[0:15]}; });
    void'(std::randomize(id)  with { id  inside {[0:31]}; });
    drive_update(pr, id, upt);
  endtask

  // Idle cycle on prio interface (no update)
  task idle_cycle();
    drive_update(4'h0, 5'd0, 1'b0);
  endtask

  virtual task body();
    int unsigned blk, i, n_attempts;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Repeat blocks: try updates "during reset", then post-reset legal updates
    for (blk = 0; blk < repeat_blocks; blk++) begin
      // Phase-A: Attempt updates during reset window (driver may hold lines, but intent is to stress)
      void'(std::randomize(n_attempts) with { n_attempts inside {[reset_attempts_min:reset_attempts_max]}; });
      // Ensure min and max show up at least once among attempts
      attempt_min_update(1'b1);
      attempt_max_update(1'b1);
      for (i = 0; i < (n_attempts > 2 ? n_attempts-2 : 0); i++) begin
        // Mix of asserted and deasserted strobes to build coverage intent
        bit st;
        void'(std::randomize(st) with { st dist {1 := 3, 0 := 1}; });
        attempt_random_update(st);
      end

      // Small gap post-reset before legal updates
      repeat (post_reset_gap) idle_cycle();

      // Phase-B: Legal priority updates after reset (accepted behavior)
      for (i = 0; i < legal_updates_cnt; i++) begin
        // Random legal update, strobe asserted
        attempt_random_update(1'b1);
        // Follow with a couple idle cycles between updates
        repeat ($urandom_range(1,3)) idle_cycle();
      end

      // Tail idle between blocks
      repeat ($urandom_range(2,5)) idle_cycle();
    end
  endtask
endclass