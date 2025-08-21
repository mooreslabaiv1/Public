
class rr_request_priority_update_with_illegal_id_and_priority_encoding_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_priority_update_with_illegal_id_and_priority_encoding_sequence)

  // Constrained-random knobs to structure traffic across phases
  rand int unsigned pre_idle_cycles;       // idle after reset before establishing baseline
  rand int unsigned normal_cycles;         // baseline "normal operation" cycles
  rand int unsigned illegal_window_cycles; // cycles to overlap with "illegal" prio update attempts
  rand int unsigned recovery_cycles;       // cycles after illegal attempts to ensure recovery
  rand int unsigned tail_idle_cycles;      // final idle cycles
  rand int unsigned ack_high_pct;          // percentage of cycles with ack=1

  constraint c_knobs {
    pre_idle_cycles       inside {[6:12]};
    normal_cycles         inside {[24:48]};
    illegal_window_cycles inside {[16:32]};
    recovery_cycles       inside {[24:48]};
    tail_idle_cycles      inside {[6:12]};
    ack_high_pct          inside {[20:60]}; // 20%..60% ack asserted across the run
  }

  function new(string name = "rr_request_priority_update_with_illegal_id_and_priority_encoding_sequence");
    super.new(name);
  endfunction

  // Drive one cycle with explicit values via CRV
  task drive_req_ack(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Idle for N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_req_ack(32'h0000_0000, 1'b0);
    end
  endtask

  // Generate a random one-hot requestor mask
  function logic [31:0] gen_onehot();
    int unsigned id;
    void'(std::randomize(id) with { id inside {[0:31]}; });
    return (32'h1 << id);
  endfunction

  // Generate a dense, high-activity mask (OR of random and two one-hots)
  function logic [31:0] gen_dense();
    logic [31:0] rnd_any;
    int unsigned id0, id1;
    void'(std::randomize(rnd_any));
    void'(std::randomize(id0) with { id0 inside {[0:31]}; });
    void'(std::randomize(id1) with { id1 inside {[0:31]}; });
    return (rnd_any | (32'h1 << id0) | (32'h1 << id1));
  endfunction

  // Random traffic driver for a given number of cycles
  task drive_random_traffic(int unsigned cycles, bit favor_dense = 0);
    int unsigned i;
    for (i = 0; i < cycles; i++) begin
      int sel;
      bit ack_v;
      logic [31:0] req_v;

      sel = $urandom_range(0,99);
      if (favor_dense) begin
        // Bias towards dense activity in "illegal window"
        if (sel < 10)       req_v = 32'h0000_0000;
        else if (sel < 20)  req_v = 32'hFFFF_FFFF;
        else if (sel < 50)  req_v = gen_onehot();
        else                req_v = gen_dense();
      end
      else begin
        // Balanced patterns for normal/recovery windows
        if (sel < 15)       req_v = 32'h0000_0000;
        else if (sel < 35)  req_v = gen_onehot();
        else if (sel < 45)  req_v = 32'hFFFF_FFFF;
        else                req_v = gen_dense();
      end

      // Ack distribution based on ack_high_pct
      ack_v = ($urandom_range(0,99) < ack_high_pct);

      drive_req_ack(req_v, ack_v);
    end
  endtask

  virtual task body();
    // Randomize top-level knobs
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request knobs")
    end

    // Publish timing to coordinate with prio_update seq (optional consumers)
    uvm_config_db#(int)::set(null, "*", "pre_idle_cycles",        pre_idle_cycles);
    uvm_config_db#(int)::set(null, "*", "illegal_window_cycles",  illegal_window_cycles);
    uvm_config_db#(int)::set(null, "*", "recovery_cycles",        recovery_cycles);
    uvm_config_db#(int)::set(null, "*", "tail_idle_cycles",       tail_idle_cycles);

    // Phase-1: Pre-idle after reset
    idle_n(pre_idle_cycles);

    // Phase-2: Establish normal operation (baseline arbitration)
    drive_random_traffic(normal_cycles, /*favor_dense*/ 0);

    // Phase-3: High-activity window to overlap with "illegal" prio updates
    // Note: prio_update sequence will attempt illegal encodings in this window.
    drive_random_traffic(illegal_window_cycles, /*favor_dense*/ 1);

    // Phase-4: Recovery window to ensure DUT resumes normal arbitration
    drive_random_traffic(recovery_cycles, /*favor_dense*/ 0);

    // Phase-5: Tail idle
    idle_n(tail_idle_cycles);
  endtask
endclass