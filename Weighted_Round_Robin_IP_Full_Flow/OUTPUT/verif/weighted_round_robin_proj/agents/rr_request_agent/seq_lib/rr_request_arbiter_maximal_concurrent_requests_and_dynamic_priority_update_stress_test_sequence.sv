


class rr_request_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence)

  // Drive at least 5000 cycles of continuous traffic, varying req pattern and ack backpressure
  rand int unsigned total_cycles;
  rand int unsigned pct_all_ones;     // percentage chance for all-ones pattern
  rand int unsigned pct_onehot;       // percentage chance for one-hot pattern
  rand int unsigned pct_random;       // percentage chance for random dense pattern
  rand int unsigned pct_all_zero;     // small chance to insert all-zeros
  rand int unsigned backpressure_prob;// probability to start a backpressure window
  rand int unsigned bp_len_min;
  rand int unsigned bp_len_max;
  rand int unsigned rec_len_min;
  rand int unsigned rec_len_max;

  constraint c_core {
    total_cycles inside {[5000:9000]};
    // Pattern selection probabilities sum to 100
    pct_all_ones inside {[30:50]};
    pct_onehot   inside {[15:30]};
    pct_random   inside {[20:45]};
    pct_all_zero inside {[0:5]};
    (pct_all_ones + pct_onehot + pct_random + pct_all_zero) == 100;

    // Backpressure windows and recovery lengths
    backpressure_prob inside {[10:30]}; // 10-30% chance to start a low-ack window
    bp_len_min inside {[2:6]};
    bp_len_max inside {[6:14]};
    bp_len_max >= bp_len_min;

    rec_len_min inside {[2:6]};
    rec_len_max inside {[6:14]};
    rec_len_max >= rec_len_min;
  }

  function new(string name="rr_request_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence");
    super.new(name);
  endfunction

  // Send one cycle with given values
  task send_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Generate a randomized request vector based on weighted pattern selection
  function logic [31:0] gen_req();
    int rsel;
    int id0, id1;
    logic [31:0] req_v, rnd_any;
    rsel = $urandom_range(0,99);

    if (rsel < pct_all_zero) begin
      return 32'h0000_0000;
    end
    else if (rsel < (pct_all_zero + pct_all_ones)) begin
      return 32'hFFFF_FFFF;
    end
    else if (rsel < (pct_all_zero + pct_all_ones + pct_onehot)) begin
      id0 = $urandom_range(0,31);
      return (32'h1 << id0);
    end
    else begin
      // Dense random: OR of a random word and two one-hot picks to keep activity high
      id0 = $urandom_range(0,31);
      id1 = $urandom_range(0,31);
      rnd_any = $urandom();
      req_v = rnd_any | (32'h1 << id0) | (32'h1 << id1);
      return req_v;
    end
  endfunction

  virtual task body();
    int unsigned i;
    int unsigned bp_rem = 0;  // remaining cycles of backpressure (ack=0)
    int unsigned rc_rem = 0;  // remaining cycles of recovery (ack=1)
    logic [31:0] req_v;
    bit ack_v;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize top-level knobs for rr_request stress sequence")
    end

    // Start in a recovery window to ensure initial progress
    void'(std::randomize(rc_rem) with { rc_rem inside {[rec_len_min:rec_len_max]}; });
    bp_rem = 0;

    for (i = 0; i < total_cycles; i++) begin
      // Backpressure/recovery window management
      if (bp_rem == 0 && rc_rem == 0) begin
        // Start a new window; decide whether to start backpressure
        if ($urandom_range(0,99) < backpressure_prob) begin
          void'(std::randomize(bp_rem) with { bp_rem inside {[bp_len_min:bp_len_max]}; });
          rc_rem = 0;
        end
        else begin
          void'(std::randomize(rc_rem) with { rc_rem inside {[rec_len_min:rec_len_max]}; });
          bp_rem = 0;
        end
      end

      if (bp_rem > 0) begin
        ack_v = 1'b0;
        bp_rem--;
      end
      else if (rc_rem > 0) begin
        ack_v = 1'b1;
        rc_rem--;
      end
      else begin
        // Single-cycle fallback if both counters somehow zero
        ack_v = ($urandom_range(0,1) == 1);
      end

      // Request pattern generation
      req_v = gen_req();

      // Send this cycle
      send_cycle(req_v, ack_v);
    end

    // Insert a few deterministic corner cycles to push coverage edges
    send_cycle(32'hFFFF_FFFF, 1'b1); // saturated with ack
    send_cycle(32'hFFFF_FFFF, 1'b0); // saturated with backpressure
    send_cycle(32'h0000_0001, 1'b1); // min ID one-hot with ack
    send_cycle(32'h8000_0000, 1'b0); // max ID one-hot with backpressure
  endtask
endclass