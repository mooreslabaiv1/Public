
class rr_request_priority_update_attempted_during_reset_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_priority_update_attempted_during_reset_sequence)

  // Constrained-random knobs controlling stimulus phases
  rand int unsigned reset_idle_cycles;           // cycles to idle around reset
  rand int unsigned post_reset_all_active_len;   // cycles to drive all requestors active
  rand int unsigned post_reset_onehot_walk_len;  // number of one-hot steps after all-active phase
  rand int unsigned tail_idle_cycles;            // trailing idle cycles
  rand int unsigned repeats;                     // repeat the post-reset pattern multiple times

  constraint c_knobs {
    reset_idle_cycles           inside {[6:12]};
    post_reset_all_active_len   inside {[8:20]};
    post_reset_onehot_walk_len  inside {[8:24]};
    tail_idle_cycles            inside {[3:8]};
    repeats                     inside {[1:3]};
  }

  function new(string name = "rr_request_priority_update_attempted_during_reset_sequence");
    super.new(name);
  endfunction

  // Drive one transaction cycle with given values
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr_loc;
    tr_loc = rr_request_trans_item::type_id::create("tr_req", , get_full_name());
    start_item(tr_loc);
    if (!tr_loc.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr_loc);
  endtask

  // Idle for N cycles
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // All requestors active burst with ack toggling
  task all_active_burst(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_cycle(32'hFFFF_FFFF, (i % 2));
    end
  endtask

  // One-hot walk with randomized ack
  task onehot_walk(int unsigned steps);
    int unsigned i;
    int unsigned id;
    for (i = 0; i < steps; i++) begin
      void'(std::randomize(id) with { id inside {[0:31]}; });
      drive_cycle(32'h1 << id[4:0], $urandom_range(0,1));
    end
  endtask

  virtual task body();
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request sequence knobs")
    end

    // Phase-1: While rst asserted by the base clk/rst sequence, keep inputs idle
    idle_n(reset_idle_cycles);

    // Phase-2..N: After reset deassertion, drive traffic to observe default-priority arbitration
    repeat (repeats) begin
      all_active_burst(post_reset_all_active_len);
      onehot_walk(post_reset_onehot_walk_len);
      // Insert occasional corner patterns
      drive_cycle(32'h0000_0001, 1'b0); // min ID
      drive_cycle(32'h8000_0000, 1'b1); // max ID
      drive_cycle(32'h0000_0000, 1'b0); // idle gap
    end

    // Tail idle
    idle_n(tail_idle_cycles);
  endtask
endclass