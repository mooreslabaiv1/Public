
class rr_grant_monitor_priority_update_with_illegal_id_and_priority_encoding_sequence extends rr_grant_monitor_base_seq;
  `uvm_object_utils(rr_grant_monitor_priority_update_with_illegal_id_and_priority_encoding_sequence)

  // Passive pacing knobs
  rand int unsigned pre_sample_cycles;
  rand int unsigned main_sample_cycles;
  rand int unsigned tail_sample_cycles;
  rand int unsigned burst_prob;
  rand int unsigned burst_len_min;
  rand int unsigned burst_len_max;

  constraint c_knobs {
    pre_sample_cycles  inside {[10:20]};
    main_sample_cycles inside {[160:320]};
    tail_sample_cycles inside {[10:20]};
    burst_prob         inside {[25:60]};
    burst_len_min      inside {[2:5]};
    burst_len_max      inside {[6:12]};
    burst_len_max >= burst_len_min;
  }

  function new(string name = "rr_grant_monitor_priority_update_with_illegal_id_and_priority_encoding_sequence");
    super.new(name);
  endfunction

  // Emit one pacing item (monitor-only transaction)
  task emit_item(string tag);
    rr_grant_monitor_trans_item gtr;
    gtr = rr_grant_monitor_trans_item::type_id::create($sformatf("gtr_%s", tag), , get_full_name());
    start_item(gtr);
    void'(gtr.randomize());
    finish_item(gtr);
  endtask

  virtual task body();
    int unsigned i, burst_rem;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize grant monitor pacing knobs")
    end

    // Pre-sampling
    for (i = 0; i < pre_sample_cycles; i++) emit_item("pre");

    // Main sampling with random bursts
    burst_rem = 0;
    for (i = 0; i < main_sample_cycles; i++) begin
      if (burst_rem == 0) begin
        if ($urandom_range(0,99) < burst_prob) begin
          void'(std::randomize(burst_rem) with { burst_rem inside {[burst_len_min:burst_len_max]}; });
        end
      end
      else begin
        burst_rem--;
      end
      emit_item("main");
    end

    // Tail sampling
    for (i = 0; i < tail_sample_cycles; i++) emit_item("tail");
  endtask
endclass