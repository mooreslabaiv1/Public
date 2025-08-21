
class rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence extends rr_grant_monitor_base_seq;
  `uvm_object_utils(rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence)

  // Passive pacing knobs
  rand int unsigned pre_sample_cycles;
  rand int unsigned sample_cycles_main;
  rand int unsigned tail_cycles;

  constraint c_knobs {
    pre_sample_cycles inside {[10:30]};
    sample_cycles_main inside {[1200:2000]}; // long enough to cover >=1000 throughput cycles plus reset windows
    tail_cycles inside {[20:60]};
  }

  function new(string name = "rr_grant_monitor_synchronous_reset_stress_with_back_to_back_requests_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_grant_monitor_trans_item gtr;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize grant monitor pacing knobs")
    end

    // Pre-sampling
    repeat (pre_sample_cycles) begin
      gtr = rr_grant_monitor_trans_item::type_id::create("gtr_pre",,get_full_name());
      start_item(gtr);
      void'(gtr.randomize());
      finish_item(gtr);
    end

    // Main sampling window
    repeat (sample_cycles_main) begin
      gtr = rr_grant_monitor_trans_item::type_id::create("gtr_main",,get_full_name());
      start_item(gtr);
      void'(gtr.randomize());
      finish_item(gtr);
    end

    // Tail sampling
    repeat (tail_cycles) begin
      gtr = rr_grant_monitor_trans_item::type_id::create("gtr_tail",,get_full_name());
      start_item(gtr);
      void'(gtr.randomize());
      finish_item(gtr);
    end
  endtask
endclass