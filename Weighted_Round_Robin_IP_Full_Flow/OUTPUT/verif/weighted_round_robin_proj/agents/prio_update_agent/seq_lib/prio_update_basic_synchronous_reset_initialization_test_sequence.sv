

class prio_update_basic_synchronous_reset_initialization_test_sequence extends prio_update_base_sequence;

  `uvm_object_utils(prio_update_basic_synchronous_reset_initialization_test_sequence)

  // Keep prio/prio_id/prio_upt at reset defaults for this test
  rand int unsigned idle_cycles_total;

  constraint c_idle_cycles_total { idle_cycles_total inside {[24:48]}; }

  function new(string name = "prio_update_basic_synchronous_reset_initialization_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    prio_update_trans_item pu_tr;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Drive no updates throughout this test; maintain zeros
    repeat (idle_cycles_total) begin
      pu_tr = prio_update_trans_item::type_id::create("pu_idle");
      start_item(pu_tr);
      if (!pu_tr.randomize() with {
            prio     == 4'h0;
            prio_id  == 5'd0;
            prio_upt == 1'b0;
          }) begin
        `uvm_error(get_full_name(), "Randomization failed for prio_update idle phase")
      end
      finish_item(pu_tr);
    end
  endtask : body

endclass