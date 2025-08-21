

class rr_request_basic_synchronous_reset_initialization_test_sequence extends rr_request_base_sequence;

  `uvm_object_utils(rr_request_basic_synchronous_reset_initialization_test_sequence)

  // Random knobs to control sequence phasing
  rand int unsigned idle_cycles_before_req;   // cycles with req=0, ack=0 (covers reset window + 2 cycles after)
  rand int unsigned drive_cycles_min_idx;     // cycles to drive req[0]=1
  rand int unsigned drive_cycles_max_idx;     // cycles to drive req[31]=1
  rand bit          do_second_request;        // optionally drive the max index requestor

  constraint c_knobs {
    idle_cycles_before_req inside {[6:12]};   // >= 6 cycles to cover reset hold plus post-reset idle window
    drive_cycles_min_idx inside {[3:5]};
    drive_cycles_max_idx inside {[3:5]};
    // Bias to often include second request phase
    do_second_request dist {1 := 3, 0 := 1};
  }

  function new(string name = "rr_request_basic_synchronous_reset_initialization_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_request_trans_item tr;

    // Randomize high-level knobs
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize sequence control knobs")
    end

    // Phase 0: Hold all inputs low during reset and for a couple cycles after deassertion
    repeat (idle_cycles_before_req) begin
      tr = rr_request_trans_item::type_id::create("tr_idle");
      start_item(tr);
      if (!tr.randomize() with { req == 32'h0000_0000; ack == 1'b0; }) begin
        `uvm_error(get_full_name(), "Randomization failed for idle phase")
      end
      finish_item(tr);
    end

    // Phase 1: Drive a single request on min index (0) for several cycles; ack randomized
    repeat (drive_cycles_min_idx) begin
      tr = rr_request_trans_item::type_id::create("tr_min_idx");
      start_item(tr);
      if (!tr.randomize() with {
            req == 32'h0000_0001; // req[0]=1
            // Randomize ack with a slight bias toward no-ack to observe stable grant
            ack dist { 1'b0 := 3, 1'b1 := 1 };
          }) begin
        `uvm_error(get_full_name(), "Randomization failed for min-index request phase")
      end
      finish_item(tr);
    end

    // Phase 2 (optional): Drive a single request on max index (31) for several cycles
    if (do_second_request) begin
      repeat (drive_cycles_max_idx) begin
        tr = rr_request_trans_item::type_id::create("tr_max_idx");
        start_item(tr);
        if (!tr.randomize() with {
              req == (32'h1 << 31); // req[31]=1
              // Keep ack randomized as well
              ack dist { 1'b0 := 2, 1'b1 := 2 };
            }) begin
          `uvm_error(get_full_name(), "Randomization failed for max-index request phase")
        end
        finish_item(tr);
      end
    end

    // Tail phase: a few idle cycles to let arbitration settle
    repeat ($urandom_range(2,5)) begin
      tr = rr_request_trans_item::type_id::create("tr_tail_idle");
      start_item(tr);
      if (!tr.randomize() with { req == 32'h0000_0000; ack == 1'b0; }) begin
        `uvm_error(get_full_name(), "Randomization failed for tail idle phase")
      end
      finish_item(tr);
    end
  endtask : body

endclass