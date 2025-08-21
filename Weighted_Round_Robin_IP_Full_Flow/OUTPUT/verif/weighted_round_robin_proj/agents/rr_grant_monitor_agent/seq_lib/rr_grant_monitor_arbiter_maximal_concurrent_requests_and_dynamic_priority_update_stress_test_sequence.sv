
class rr_grant_monitor_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence extends rr_grant_monitor_base_seq;
  `uvm_object_utils(rr_grant_monitor_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence)

  // Passive pacing for sampling over a long window
  rand int unsigned sample_cycles;
  rand int unsigned burst_prob;     // probability to create a short burst of items
  rand int unsigned burst_len_min;
  rand int unsigned burst_len_max;

  constraint c_knobs {
    sample_cycles inside {[5500:10000]};
    burst_prob inside {[20:60]};
    burst_len_min inside {[2:6]};
    burst_len_max inside {[8:16]};
    burst_len_max >= burst_len_min;
  }

  function new(string name="rr_grant_monitor_arbiter_maximal_concurrent_requests_and_dynamic_priority_update_stress_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_grant_monitor_trans_item gtr;
    int unsigned i;
    int unsigned burst_rem = 0;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_grant_monitor pacing knobs")
    end

    for (i = 0; i < sample_cycles; i++) begin
      // Occasionally start a burst to keep the driver/monitor sync exercised
      if (burst_rem == 0) begin
        if ($urandom_range(0,99) < burst_prob) begin
          void'(std::randomize(burst_rem) with { burst_rem inside {[burst_len_min:burst_len_max]}; });
        end
      end
      else begin
        burst_rem--;
      end

      gtr = rr_grant_monitor_trans_item::type_id::create($sformatf("gtr_samp_%0d", i),,get_full_name());
      start_item(gtr);
      // No fields to drive; still randomize object per CRV methodology
      void'(gtr.randomize());
      finish_item(gtr);
    end
  endtask
endclass