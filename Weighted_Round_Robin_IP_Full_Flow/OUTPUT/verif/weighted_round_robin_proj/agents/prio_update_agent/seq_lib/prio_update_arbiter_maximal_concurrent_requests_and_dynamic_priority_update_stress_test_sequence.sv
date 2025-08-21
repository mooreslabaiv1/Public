

class prio_update_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence)

  // Long window with randomized updates including bursts; ensure all IDs get min/max once
  rand int unsigned total_cycles;
  rand int unsigned update_pct;     // 10-50% probability of asserting prio_upt in a cycle
  rand int unsigned burst_start_pct;// chance to start a consecutive update burst
  rand int unsigned burst_len_min;
  rand int unsigned burst_len_max;

  constraint c_knobs {
    total_cycles inside {[5200:9000]};
    update_pct inside {[10:50]};
    burst_start_pct inside {[15:35]};
    burst_len_min inside {[2:8]};
    burst_len_max inside {[8:20]};
    burst_len_max >= burst_len_min;
  }

  function new(string name="prio_update_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence");
    super.new(name);
  endfunction

  // Drive a single cycle
  task drive_cycle(bit strobe, logic [4:0] id_v, logic [3:0] pr_v);
    prio_update_trans_item tr;
    tr = prio_update_trans_item::type_id::create("pu_tr",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { prio_upt == strobe; prio_id == id_v; prio == pr_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(tr);
  endtask

  // Randomize id and prio for this cycle
  function void pick_rand(ref logic [4:0] id_v, ref logic [3:0] pr_v);
    void'(std::randomize(id_v) with { id_v inside {[0:31]}; });
    void'(std::randomize(pr_v) with { pr_v inside {[0:15]}; });
  endfunction

  virtual task body();
    // Declarations at the beginning of the task
    bit [31:0] did_min;
    bit [31:0] did_max;
    int unsigned i;
    int unsigned burst_rem;
    logic [4:0] id_v;
    logic [3:0] pr_v;
    bit strobe;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Initialize tracking
    did_min = '0;
    did_max = '0;

    burst_rem = 0;

    // Main randomized window
    for (i = 0; i < total_cycles; i++) begin
      // Manage bursts of consecutive updates
      if (burst_rem == 0) begin
        if ($urandom_range(0,99) < burst_start_pct) begin
          void'(std::randomize(burst_rem) with { burst_rem inside {[burst_len_min:burst_len_max]}; });
        end
      end

      if (burst_rem > 0) begin
        strobe = 1'b1;
        burst_rem--;
      end
      else begin
        strobe = ($urandom_range(0,99) < update_pct);
      end

      if (strobe) begin
        pick_rand(id_v, pr_v);
        if (pr_v == 4'h0) did_min[id_v] = 1'b1;
        if (pr_v == 4'hF) did_max[id_v] = 1'b1;
        drive_cycle(1'b1, id_v, pr_v);
      end
      else begin
        // No update this cycle; hold lines but still send a transaction
        drive_cycle(1'b0, 5'd0, 4'h0);
      end
    end

    // Directed sweeps to guarantee bins:
    // 1) All requestors to max priority (consecutive cycles)
    for (i = 0; i < 32; i++) begin
      drive_cycle(1'b1, i[4:0], 4'hF);
      did_max[i] = 1'b1;
    end

    // 2) All requestors to min priority (consecutive cycles)
    for (i = 0; i < 32; i++) begin
      drive_cycle(1'b1, i[4:0], 4'h0);
      did_min[i] = 1'b1;
    end

    // 3) Ensure each requestor saw both min and max at least once
    for (i = 0; i < 32; i++) begin
      if (!did_max[i]) drive_cycle(1'b1, i[4:0], 4'hF);
      if (!did_min[i]) drive_cycle(1'b1, i[4:0], 4'h0);
    end

    // Tail random burst to overlap with request acks, increasing chance of coincidence
    begin
      int unsigned tail_burst;
      tail_burst = $urandom_range(12, 24);
      for (i = 0; i < tail_burst; i++) begin
        pick_rand(id_v, pr_v);
        drive_cycle(1'b1, id_v, pr_v);
      end
    end
  endtask
endclass