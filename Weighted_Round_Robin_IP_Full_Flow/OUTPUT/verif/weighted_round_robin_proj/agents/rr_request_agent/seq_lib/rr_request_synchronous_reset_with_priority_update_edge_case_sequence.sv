
class rr_request_synchronous_reset_with_priority_update_edge_case_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_synchronous_reset_with_priority_update_edge_case_sequence)

  // Constrained-random knobs to exercise normal arbitration before/after priority updates
  rand int unsigned pre_normal_cycles;     // initial normal operation cycles
  rand int unsigned traffic_cycles;        // subsequent randomized traffic cycles
  rand int unsigned onehot_pct;            // probability of one-hot request
  rand int unsigned dense_pct;             // probability of dense request
  rand int unsigned all_zeros_pct;         // probability of all-zeros (idle)
  rand int unsigned all_ones_pct;          // probability of all-ones (stress)
  rand int unsigned ack_high_pct;          // probability ack=1 in a cycle

  constraint c_knobs {
    pre_normal_cycles inside {[5:12]};
    traffic_cycles    inside {[160:300]};
    onehot_pct        inside {[40:65]};    // bias toward legal one-hot patterns
    dense_pct         inside {[10:25]};
    all_zeros_pct     inside {[5:15]};
    all_ones_pct      inside {[5:15]};
    (onehot_pct + dense_pct + all_zeros_pct + all_ones_pct) == 100;
    ack_high_pct      inside {[30:60]};
  }

  function new(string name = "rr_request_synchronous_reset_with_priority_update_edge_case_sequence");
    super.new(name);
  endfunction

  // Drive a single cycle using CRV with explicit values
  task drive_req_ack(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr_loc;
    tr_loc = rr_request_trans_item::type_id::create("tr_loc",,get_full_name());
    start_item(tr_loc);
    if (!tr_loc.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr_loc);
  endtask

  // Idle for N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) drive_req_ack(32'h0000_0000, 1'b0);
  endtask

  // Generate one-hot mask
  function logic [31:0] gen_onehot();
    int unsigned id;
    void'(std::randomize(id) with { id inside {[0:31]}; });
    return (32'h1 << id);
  endfunction

  // Generate dense mask
  function logic [31:0] gen_dense();
    logic [31:0] rnd_any;
    int unsigned id0, id1;
    void'(std::randomize(rnd_any));
    void'(std::randomize(id0) with { id0 inside {[0:31]}; });
    void'(std::randomize(id1) with { id1 inside {[0:31]}; });
    return (rnd_any | (32'h1 << id0) | (32'h1 << id1));
  endfunction

  virtual task body();
    int unsigned i, sel;
    logic [31:0] req_v;
    bit ack_v;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request knobs")
    end

    // Phase-1: Normal arbitration window
    for (i = 0; i < pre_normal_cycles; i++) begin
      sel = $urandom_range(0,99);
      if (sel < all_zeros_pct)          req_v = 32'h0000_0000;
      else if (sel < (all_zeros_pct + all_ones_pct)) req_v = 32'hFFFF_FFFF;
      else if (sel < (all_zeros_pct + all_ones_pct + onehot_pct)) req_v = gen_onehot();
      else                                   req_v = gen_dense();
      ack_v = ($urandom_range(0,99) < ack_high_pct);
      drive_req_ack(req_v, ack_v);
    end

    // Phase-2: Continued randomized traffic after priority-update edge cases
    for (i = 0; i < traffic_cycles; i++) begin
      sel = $urandom_range(0,99);
      if (sel < all_zeros_pct)          req_v = 32'h0000_0000;
      else if (sel < (all_zeros_pct + all_ones_pct)) req_v = 32'hFFFF_FFFF;
      else if (sel < (all_zeros_pct + all_ones_pct + onehot_pct)) req_v = gen_onehot();
      else                                   req_v = gen_dense();
      ack_v = ($urandom_range(0,99) < ack_high_pct);
      drive_req_ack(req_v, ack_v);
    end

    // Tail: a few directed corners
    drive_req_ack(32'h0000_0001, 1'b0); // min ID
    drive_req_ack(32'h8000_0000, 1'b1); // max ID with ack
    idle_n($urandom_range(3,6));
  endtask
endclass