
class rr_request_reset_deasserted_mid_cycle_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_reset_deasserted_mid_cycle_sequence)

  // Constrained-random knobs for stimulus shaping post-reset
  rand int unsigned idle_cycles_after_reset;   // settle time after rst deassertion
  rand int unsigned traffic_cycles;            // number of active traffic cycles
  rand int unsigned onehot_pct;                // percentage of one-hot requests
  rand int unsigned all_ones_pct;              // percentage of all-ones requests
  rand int unsigned zero_pct;                  // percentage of all-zero requests (idle)
  rand int unsigned ack_high_pct;              // percentage of cycles with ack=1

  constraint c_knobs {
    idle_cycles_after_reset inside {[3:8]};
    traffic_cycles          inside {[120:220]};
    onehot_pct              inside {[40:70]};  // emphasize legal one-hot
    all_ones_pct            inside {[5:20]};
    zero_pct                inside {[5:15]};
    (onehot_pct + all_ones_pct + zero_pct) <= 90; // rest goes to dense mixed masks
    ack_high_pct            inside {[30:60]};
  }

  function new(string name = "rr_request_reset_deasserted_mid_cycle_sequence");
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
    for (i = 0; i < n; i++) begin
      drive_req_ack(32'h0000_0000, 1'b0);
    end
  endtask

  // Generate a one-hot request mask
  function logic [31:0] gen_onehot();
    int unsigned id;
    void'(std::randomize(id) with { id inside {[0:31]}; });
    return (32'h1 << id);
  endfunction

  // Generate a dense mixed mask (OR of random and two one-hots)
  function logic [31:0] gen_dense();
    logic [31:0] rnd_any;
    int unsigned id0, id1;
    void'(std::randomize(rnd_any));
    void'(std::randomize(id0) with { id0 inside {[0:31]}; });
    void'(std::randomize(id1) with { id1 inside {[0:31]}; });
    return (rnd_any | (32'h1 << id0) | (32'h1 << id1));
  endfunction

  virtual task body();
    int unsigned i;
    int sel;
    logic [31:0] req_v;
    bit ack_v;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request mid-cycle reset test knobs")
    end

    // Phase-1: Initial settle time post-reset deassertion (driver waits internally for rst==0)
    idle_n(idle_cycles_after_reset);

    // Phase-2: Active traffic with legal and stress patterns
    for (i = 0; i < traffic_cycles; i++) begin
      sel = $urandom_range(0,99);
      if (sel < zero_pct) begin
        req_v = 32'h0000_0000;
      end
      else if (sel < (zero_pct + all_ones_pct)) begin
        req_v = 32'hFFFF_FFFF;
      end
      else if (sel < (zero_pct + all_ones_pct + onehot_pct)) begin
        req_v = gen_onehot();
      end
      else begin
        req_v = gen_dense();
      end

      ack_v = ($urandom_range(0,99) < ack_high_pct);
      drive_req_ack(req_v, ack_v);
    end

    // Tail: a few deterministic edge cases
    drive_req_ack(32'h0000_0001, 1'b0); // min ID
    drive_req_ack(32'h8000_0000, 1'b1); // max ID with ack
    idle_n($urandom_range(2,4));
  endtask
endclass