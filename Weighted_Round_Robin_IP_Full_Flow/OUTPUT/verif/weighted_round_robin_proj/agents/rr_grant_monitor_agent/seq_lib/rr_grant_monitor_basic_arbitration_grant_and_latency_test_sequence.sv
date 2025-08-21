
class rr_grant_monitor_basic_arbitration_grant_and_latency_test_sequence extends rr_grant_monitor_base_seq;
  `uvm_object_utils(rr_grant_monitor_basic_arbitration_grant_and_latency_test_sequence)

  // Passive sampling sequence; emit randomized pacing items to coordinate with monitor
  rand int unsigned sample_cycles;
  rand int unsigned burst_len_min;
  rand int unsigned burst_len_max;

  constraint c_knobs {
    sample_cycles inside {[80:200]};
    burst_len_min inside {[1:3]};
    burst_len_max inside {[4:8]};
    burst_len_max >= burst_len_min;
  }

  function new(string name = "rr_grant_monitor_basic_arbitration_grant_and_latency_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_grant_monitor_trans_item gtr;
    int unsigned i;
    int unsigned burst, j;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize grant monitor sequence knobs")
    end

    i = 0;
    while (i < sample_cycles) begin
      // random mini-bursts of sampling items
      void'(std::randomize(burst) with { burst inside {[burst_len_min:burst_len_max]}; });
      for (j = 0; (j < burst) && (i < sample_cycles); j++, i++) begin
        gtr = rr_grant_monitor_trans_item::type_id::create($sformatf("gtr_samp_%0d", i),,get_full_name());
        start_item(gtr);
        // fields are observed, not driven; still follow CRV
        void'(gtr.randomize());
        finish_item(gtr);
      end
    end
  endtask
endclass