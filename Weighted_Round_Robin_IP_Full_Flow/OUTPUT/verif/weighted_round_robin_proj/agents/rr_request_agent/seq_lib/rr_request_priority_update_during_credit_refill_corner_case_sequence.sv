

class rr_request_priority_update_during_credit_refill_corner_case_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_priority_update_during_credit_refill_corner_case_sequence)

  // Shared configuration keys with prio_update sequence
  localparam string CFG_PRE_IDLE = "refill_pre_idle_cycles";
  localparam string CFG_ZERO_LEN = "refill_zero_len";
  localparam string CFG_ONES_LEN = "refill_ones_len";

  // Constrained-random knobs
  rand int unsigned pre_idle_cycles; // initial all-zero cycles after reset
  rand int unsigned zero_len;        // number of cycles to hold req=0 per ID (refill window)
  rand int unsigned ones_len;        // number of cycles to hold req=all 1's after refill

  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    zero_len        inside {[1:3]};
    ones_len        inside {[2:5]};
  }

  function new(string name = "rr_request_priority_update_during_credit_refill_corner_case_sequence");
    super.new(name);
  endfunction

  // Drive one cycle with explicit req/ack values via CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item in drive_cycle()")
    end
    finish_item(tr);
  endtask

  // Idle N cycles with req=0, ack=0
  task idle_n(int unsigned n);
    for (int unsigned i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Per-ID window: first zero_len cycles of req=0 (no grant => refill), then ones_len cycles of req=all 1's
  task do_id_window();
    int unsigned ack_idx;
    int unsigned i;

    // Refill window: hold zeros (no eligible -> credit refill)
    idle_n(zero_len);

    // After refill, assert all requestors to observe first grant after updated priority
    void'(std::randomize(ack_idx) with { ack_idx inside {[0: (ones_len>0)?(ones_len-1):0]}; });
    for (i = 0; i < ones_len; i++) begin
      drive_cycle(32'hFFFF_FFFF, (i == ack_idx));
    end
  endtask

  virtual task body();
    // Two passes: pass 0 -> prio=0, pass 1 -> prio=15 (prio values are driven by the prio_update sequence)
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request knobs")
    end

    // Publish chosen knobs so prio_update seq can align its strobe exactly at refill (last zero cycle)
    uvm_config_db#(int)::set(null, "*", CFG_PRE_IDLE, pre_idle_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_ZERO_LEN, zero_len);
    uvm_config_db#(int)::set(null, "*", CFG_ONES_LEN, ones_len);

    // Pre-idle: ensure DUT is out of reset and stable
    idle_n(pre_idle_cycles);

    // Pass 0: min priority will be programmed by prio_update seq during refill for each ID
    for (int unsigned id = 0; id < 32; id++) begin
      do_id_window();
    end

    // Small all-zero gap before second pass to clearly separate two runs
    idle_n($urandom_range(3,7));

    // Pass 1: max priority will be programmed by prio_update seq during refill for each ID
    for (int unsigned id = 0; id < 32; id++) begin
      do_id_window();
    end

    // Tail idle
    idle_n($urandom_range(4,8));
  endtask
endclass