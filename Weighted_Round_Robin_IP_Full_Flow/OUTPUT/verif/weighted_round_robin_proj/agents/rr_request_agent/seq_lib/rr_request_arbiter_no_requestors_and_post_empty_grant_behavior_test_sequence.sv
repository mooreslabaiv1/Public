
class rr_request_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence extends rr_request_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_request_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_request_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence)

  // Constrained-random knobs shaping the directed-empty and post-empty single requester phases
  rand int unsigned init_empty_cycles;       // initial all-zeros req window after reset and prio programming
  rand int unsigned gap_empty_min;           // min cycles of all-zeros between each single requester activation
  rand int unsigned gap_empty_max;           // max cycles of all-zeros between each single requester activation
  rand int unsigned onehot_hold_cycles;      // cycles to hold a single requester asserted
  rand int unsigned tail_empty_cycles;       // final all-zeros window to observe idle grants

  constraint c_knobs {
    init_empty_cycles inside {[5:9]};        // at least 5 cycles empty per spec
    gap_empty_min     inside {[1:2]};
    gap_empty_max     inside {[3:6]};
    gap_empty_max >= gap_empty_min;
    onehot_hold_cycles inside {[2:3]};       // at least 2 cycles per spec
    tail_empty_cycles inside {[10:16]};      // at least 10 cycles per spec
  }

  function new(string name="rr_request_arbiter_no_requestors_and_post_empty_grant_behavior_test_sequence");
    super.new(name);
  endfunction

  // Drive a single cycle with explicit values via CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Idle window with req=0 and ack=0 for N cycles
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Activate one requester (one-hot) for onehot_hold_cycles; assert ack for one of those cycles
  task activate_single(int unsigned id);
    int unsigned i;
    logic [31:0] mask;
    bit ack_v;
    mask = (32'h1 << id[4:0]);

    for (i = 0; i < onehot_hold_cycles; i++) begin
      // Bias ack to be asserted on the second cycle when available
      if (onehot_hold_cycles >= 2) ack_v = (i == 1);
      else                         ack_v = 1'b0;
      drive_cycle(mask, ack_v);
    end
  endtask

  virtual task body();
    int unsigned id;
    int unsigned gap;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request no-requestors/post-empty knobs")
    end

    // Step-4: All req low for at least 5 cycles (init_empty_cycles randomized >=5)
    idle_n(init_empty_cycles);

    // Step-6/7: For each requestor, always start from all req low, then assert that single bit
    for (id = 0; id < 32; id++) begin
      void'(std::randomize(gap) with { gap inside {[gap_empty_min:gap_empty_max]}; });
      idle_n(gap);                 // ensure we start from an empty period
      activate_single(id);         // assert single requester and observe at least 2 cycles
    end

    // Step-8: Separate phase: keep req all zeros for at least 10 cycles
    idle_n(tail_empty_cycles);
  endtask
endclass