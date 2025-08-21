

class rr_grant_monitor_basic_synchronous_reset_initialization_test_sequence extends rr_grant_monitor_base_sequence;

  `uvm_object_utils(rr_grant_monitor_basic_synchronous_reset_initialization_test_sequence)

  // This sequence is passive in nature; it simply provides randomized pacing items
  // to align with the monitor infrastructure. No active driving of DUT signals occurs here.
  rand int unsigned sample_cycles;

  constraint c_sample_cycles { sample_cycles inside {[20:40]}; }

  function new(string name = "rr_grant_monitor_basic_synchronous_reset_initialization_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rr_grant_monitor_trans_item gtr;
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize grant monitor sequence knobs")
    end

    repeat (sample_cycles) begin
      // Create a dummy item; fields are observed by the monitor/driver as applicable.
      gtr = rr_grant_monitor_trans_item::type_id::create("gtr_sample");
      start_item(gtr);
      // No rand fields to constrain in this item; still follow CRV flow
      void'(gtr.randomize());
      finish_item(gtr);
    end
  endtask : body

endclass