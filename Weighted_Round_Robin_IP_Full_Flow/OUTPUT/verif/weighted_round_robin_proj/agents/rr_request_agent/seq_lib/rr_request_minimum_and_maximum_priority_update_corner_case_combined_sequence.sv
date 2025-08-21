
class rr_request_minimum_and_maximum_priority_update_corner_case_combined_sequence extends rr_request_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_request_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_request_minimum_and_maximum_priority_update_corner_case_combined_sequence)

  // Constrained-random knobs
  rand int unsigned pre_idle_cycles;     // cycles to keep req=0 before asserting all ones
  rand int unsigned main_cycles;         // cycles to keep req=all ones (active for duration)
  rand int unsigned ack_high_pct;        // percentage of cycles with ack=1 when not in a burst
  rand int unsigned ack_burst_prob;      // probability to start an ack burst
  rand int unsigned ack_burst_len_min;   // min ack burst length
  rand int unsigned ack_burst_len_max;   // max ack burst length

  constraint c_knobs {
    pre_idle_cycles    inside {[6:12]};
    main_cycles        inside {[1200:2000]}; // long enough to span all priority updates
    ack_high_pct       inside {[35:65]};
    ack_burst_prob     inside {[10:35]};
    ack_burst_len_min  inside {[1:3]};
    ack_burst_len_max  inside {[3:8]};
    ack_burst_len_max >= ack_burst_len_min;
  }

  function new(string name = "rr_request_minimum_and_maximum_priority_update_corner_case_combined_sequence");
    super.new(name);
  endfunction

  // Drive one cycle using CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item in drive_cycle()")
    end
    finish_item(tr);
  endtask

  // Idle helper (req=0, ack=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  virtual task body();
    int unsigned i;
    int unsigned ack_burst_rem;
    bit ack_v;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request min/max corner combined knobs")
    end

    // Step-3/4 setup: allow few idle cycles, then assert all requests for the duration.
    idle_n(pre_idle_cycles);

    // Step-4: Assert all request bits and keep them asserted for the duration; generate ack activity
    ack_burst_rem = 0;
    for (i = 0; i < main_cycles; i++) begin
      // Manage ack bursts to create single-cycle or multi-cycle acks
      if (ack_burst_rem == 0) begin
        if ($urandom_range(0,99) < ack_burst_prob) begin
          void'(std::randomize(ack_burst_rem) with { ack_burst_rem inside {[ack_burst_len_min:ack_burst_len_max]}; });
        end
      end

      if (ack_burst_rem > 0) begin
        ack_v = 1'b1;
        ack_burst_rem--;
      end
      else begin
        ack_v = ($urandom_range(0,99) < ack_high_pct);
      end

      // Keep all requestors requesting
      drive_cycle(32'hFFFF_FFFF, ack_v);
    end

    // Tail: keep requesting with ack low few more cycles to settle
    repeat ($urandom_range(4,8)) drive_cycle(32'hFFFF_FFFF, 1'b0);
  endtask
endclass