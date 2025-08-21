
class rr_request_basic_arbitration_grant_and_latency_test_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_basic_arbitration_grant_and_latency_test_sequence)

  // High-level knobs to shape stimulus (all constrained-random)
  rand int unsigned idle_cycles_post_reset;     // idle after reset
  rand int unsigned static_cycles_total;        // total cycles for static multi-request pattern
  rand int unsigned static_ack_delay;           // cycles to wait before issuing single-cycle ack
  rand int unsigned onehot_full_walk_enable;    // 0/1: do full 0..31 walk
  rand int unsigned onehot_random_count;        // additional random one-hot requests
  rand int unsigned single_req_burst_enable;    // 0/1: include repeated single requestor burst
  rand int unsigned single_req_burst_len;       // number of cycles for repeated single requestor
  rand int unsigned static_base_idx;            // base index for 2-adjacent-ones static pattern
  rand int unsigned single_req_id;              // requestor ID for single-burst
  rand int unsigned gap_cycles_between_phases;  // idle gaps between phases

  constraint c_knobs {
    idle_cycles_post_reset inside {[2:5]};
    static_cycles_total inside {[6:12]};
    static_ack_delay inside {[2:5]};
    onehot_full_walk_enable inside {0,1};
    onehot_random_count inside {[4:16]};
    single_req_burst_enable inside {0,1};
    single_req_burst_len inside {[4:12]};
    static_base_idx inside {[0:30]}; // adjacent pair fits within 0..31
    single_req_id inside {[0:31]};
    gap_cycles_between_phases inside {[1:4]};
  }

  function new(string name = "rr_request_basic_arbitration_grant_and_latency_test_sequence");
    super.new(name);
  endfunction

  // Helper: drive one cycle with given req/ack
  task drive_cycle(logic [31:0] req_v, logic ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_drive",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item with desired values")
    end
    finish_item(tr);
  endtask

  // Helper: idle N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    repeat (n) drive_cycle(32'h0000_0000, 1'b0);
  endtask

  // Phase A: static multi-request pattern (two adjacent ones), with delayed single-cycle ack
  task do_static_pattern();
    logic [31:0] req_static;
    int unsigned i;

    // Construct two-adjacent-ones pattern like 0110 shifted arbitrarily
    req_static = (32'h1 << static_base_idx) | (32'h1 << (static_base_idx+1));

    // Hold req asserted for total static_cycles_total; keep ack low for static_ack_delay, then 1 cycle high, then low.
    for (i = 0; i < static_cycles_total; i++) begin
      logic ack_v;
      if (i == static_ack_delay) ack_v = 1'b1;
      else                       ack_v = 1'b0;
      drive_cycle(req_static, ack_v);
    end
  endtask

  // Phase B: one-hot walk across all requestors (each held for 2 cycles, ack high for 1 cycle)
  task do_onehot_full_walk();
    int unsigned id;
    for (id = 0; id < 32; id++) begin
      logic [31:0] req_mask;
      req_mask = (32'h1 << id);
      // Hold for 2 cycles; assert ack once as per requirement
      drive_cycle(req_mask, 1'b0);
      drive_cycle(req_mask, 1'b1); // acknowledge the grant
      // Deassert before moving to next
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Phase C: additional random one-hot requests (each 2 cycles with single ack)
  task do_onehot_random(int unsigned count);
    int unsigned k;
    for (k = 0; k < count; k++) begin
      int unsigned id;
      void'(std::randomize(id) with { id inside {[0:31]}; });
      // Ensure we also occasionally hit min/max explicitly
      if (k == 0) id = 0;
      else if (k == count-1) id = 31;

      // Two-cycle hold with single-cycle ack
      drive_cycle((32'h1 << id), 1'b0);
      drive_cycle((32'h1 << id), 1'b1);
      // Deassert before next
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Phase D: single requestor repeated for burst_len cycles with acks interspersed
  task do_single_req_burst(int unsigned id, int unsigned burst_len);
    int unsigned i;
    logic [31:0] req_mask;
    req_mask = (32'h1 << id);
    for (i = 0; i < burst_len; i++) begin
      // Bias ack to 1 every other cycle to exercise throughput/latency
      logic ack_v = (i % 2 == 1);
      drive_cycle(req_mask, ack_v);
    end
    // trailing idle
    drive_cycle(32'h0000_0000, 1'b0);
  endtask

  virtual task body();
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize sequence-level knobs")
    end

    // Initial idle window after reset
    idle_n(idle_cycles_post_reset);

    // Static multi-request pattern
    do_static_pattern();

    // Gap
    idle_n(gap_cycles_between_phases);

    // Full one-hot walk optionally
    if (onehot_full_walk_enable) begin
      do_onehot_full_walk();
    end

    // Gap
    idle_n(gap_cycles_between_phases);

    // Additional randomized one-hot requests
    do_onehot_random(onehot_random_count);

    // Gap
    idle_n(gap_cycles_between_phases);

    // Optional: single requestor burst
    if (single_req_burst_enable) begin
      do_single_req_burst(single_req_id, single_req_burst_len);
    end

    // Tail idle
    idle_n($urandom_range(2,5));
  endtask
endclass