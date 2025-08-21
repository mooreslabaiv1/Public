
class prio_update_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence extends prio_update_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the prio_update_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(prio_update_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence)

  // Constrained-random knobs: program all priorities to a legal nonzero value (e.g., 2) with random order and gaps
  rand int unsigned pre_idle_cycles;      // small idle after reset before updates
  rand int unsigned gap_min;              // min idle between updates
  rand int unsigned gap_max;              // max idle between updates
  rand int unsigned tail_idle_cycles;     // trailing idle cycles after completing updates
  rand logic [3:0]  programmed_prio;      // choose a legal nonzero priority

  constraint c_knobs {
    pre_idle_cycles inside {[1:4]};
    gap_min         inside {[0:2]};
    gap_max         inside {[1:4]};
    gap_max >= gap_min;
    tail_idle_cycles inside {[4:10]};
    programmed_prio inside {[1:15]};      // nonzero as per requirement
  }

  function new(string name="prio_update_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence");
    super.new(name);
  endfunction

  // Drive one cycle on priority interface
  task drive_pu(logic [3:0] pr_v, logic [4:0] id_v, bit strobe);
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
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_pu(4'h0, 5'd0, 1'b0);
    end
  endtask

  virtual task body();
    int ids[$];
    int left;
    int pick_idx;
    int gap;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update programming knobs")
    end

    // Pre-idle
    idle_n(pre_idle_cycles);

    // Prepare randomized programming order of all 32 requestors
    ids.delete();
    for (left = 0; left < 32; left++) ids.push_back(left);

    while (ids.size() > 0) begin
      // Pick a random remaining ID and program it to programmed_prio
      void'(std::randomize(pick_idx) with { pick_idx inside {[0:ids.size()-1]}; });
      drive_pu(programmed_prio, ids[pick_idx][4:0], 1'b1);
      ids.delete(pick_idx);

      // Random idle gap between updates
      void'(std::randomize(gap) with { gap inside {[gap_min:gap_max]}; });
      idle_n(gap);
    end

    // Tail idle
    idle_n(tail_idle_cycles);
  endtask
endclass