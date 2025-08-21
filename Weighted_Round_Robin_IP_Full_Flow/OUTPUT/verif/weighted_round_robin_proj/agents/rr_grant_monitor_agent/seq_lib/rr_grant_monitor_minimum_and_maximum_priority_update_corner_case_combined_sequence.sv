
class rr_grant_monitor_minimum_and_maximum_priority_update_corner_case_combined_sequence extends rr_grant_monitor_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_grant_monitor_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_grant_monitor_minimum_and_maximum_priority_update_corner_case_combined_sequence)

  // Passive pacing knobs to span the entire scenario
  rand int unsigned sample_cycles;
  rand int unsigned burst_prob;
  rand int unsigned burst_len_min;
  rand int unsigned burst_len_max;

  constraint c_knobs {
    sample_cycles inside {[1500:2500]}; // cover init + per-ID min/max + dynamic updates
    burst_prob inside {[20:50]};
    burst_len_min inside {[2:5]};
    burst_len_max inside {[6:14]};
    burst_len_max >= burst_len_min;
  }

  function new(string name = "rr_grant_monitor_minimum_and_maximum_priority_update_corner_case_combined_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_grant_monitor_trans_item gtr;
    int unsigned i, burst_rem;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize grant monitor pacing knobs (min/max combined)")
    end

    burst_rem = 0;
    for (i = 0; i < sample_cycles; i++) begin
      if (burst_rem == 0) begin
        if ($urandom_range(0,99) < burst_prob) begin
          void'(std::randomize(burst_rem) with { burst_rem inside {[burst_len_min:burst_len_max]}; });
        end
      end
      else begin
        burst_rem--;
      end

      gtr = rr_grant_monitor_trans_item::type_id::create($sformatf("gtr_minmax_%0d", i), , get_full_name());
      start_item(gtr);
      void'(gtr.randomize()); // pacing object only
      finish_item(gtr);
    end
  endtask
endclass