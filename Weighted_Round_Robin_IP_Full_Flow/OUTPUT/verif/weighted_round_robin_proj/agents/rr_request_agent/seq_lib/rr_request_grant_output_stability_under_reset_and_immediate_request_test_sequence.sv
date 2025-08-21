
class rr_request_grant_output_stability_under_reset_and_immediate_request_test_sequence extends rr_request_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_request_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_request_grant_output_stability_under_reset_and_immediate_request_test_sequence)

  // Constrained-random knobs controlling hold lengths and pacing
  rand int unsigned onehot_hold_len;   // cycles to hold a single one-hot requester
  rand int unsigned allbits_hold_len;  // cycles to hold all-ones request
  rand bit          insert_idle_gaps;  // optional small idle gaps between patterns
  rand int unsigned gap_len_min;
  rand int unsigned gap_len_max;

  constraint c_knobs {
    onehot_hold_len  inside {[2:4]};   // at least 2 cycles so ack can pulse inside
    allbits_hold_len inside {[3:6]};
    gap_len_min      inside {[0:1]};
    gap_len_max      inside {[1:3]};
    gap_len_max >= gap_len_min;
  }

  function new(string name = "rr_request_grant_output_stability_under_reset_and_immediate_request_test_sequence");
    super.new(name);
  endfunction

  // Drive exactly one cycle
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack",,get_full_name());
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
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // One-hot pattern for a given ID with a single-cycle ack somewhere inside hold window
  task do_onehot(int unsigned id, int unsigned hold_len);
    int unsigned i;
    int unsigned ack_idx;
    logic [31:0] mask;

    // Randomize ack index within [0:hold_len-1]
    if (!std::randomize(ack_idx) with { ack_idx inside {[0:hold_len-1]}; }) ack_idx = 0;

    mask = (32'h1 << id[4:0]);
    for (i = 0; i < hold_len; i++) begin
      drive_cycle(mask, (i == ack_idx));
    end
  endtask

  // All-ones pattern with a single-cycle ack somewhere inside hold window
  task do_all_ones(int unsigned hold_len);
    int unsigned i;
    int unsigned ack_idx;

    if (!std::randomize(ack_idx) with { ack_idx inside {[0:hold_len-1]}; }) ack_idx = 1;

    for (i = 0; i < hold_len; i++) begin
      drive_cycle(32'hFFFF_FFFF, (i == ack_idx));
    end
  endtask

  // Optional randomized small idle gap between directed patterns
  task optional_gap();
    int unsigned g;
    if (insert_idle_gaps) begin
      void'(std::randomize(g) with { g inside {[gap_len_min:gap_len_max]}; });
      idle_n(g);
    end
  endtask

  virtual task body();
    int unsigned id;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize knobs for immediate-after-reset request sequence")
    end

    // NOTE: The driver internally waits for reset deassert + a couple of cycles for stability.
    // We begin issuing directed "immediate-after-reset" patterns as soon as driver allows.

    // 1) Immediate directed cycle: requestor 0 one-hot
    do_onehot(0, onehot_hold_len);
    optional_gap();

    // 2) Immediately follow with all-ones request window
    do_all_ones(allbits_hold_len);
    optional_gap();

    // 3) Iterate through all single-bit request patterns, each with an ack pulse inside the hold.
    //    Include ID0 again to complete "all possible single-bit" coverage explicitly.
    for (id = 0; id < 32; id++) begin
      do_onehot(id, onehot_hold_len);
      optional_gap();
    end

    // 4) Final all-ones burst to reconfirm stability
    do_all_ones(allbits_hold_len);

    // Tail: small idle to let outputs settle
    idle_n($urandom_range(2,5));
  endtask
endclass