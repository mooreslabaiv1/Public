
class prio_update_grant_output_boundary_requestor_id_and_one_hot_test_sequence extends prio_update_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the prio_update_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(prio_update_grant_output_boundary_requestor_id_and_one_hot_test_sequence)

  // Keep priority interface idle for the duration of the test
  rand int unsigned idle_cycles_total;

  constraint c_knobs {
    idle_cycles_total inside {[140:240]};
  }

  function new(string name = "prio_update_grant_output_boundary_requestor_id_and_one_hot_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    prio_update_trans_item pu_tr;
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update idle knobs")
    end

    repeat (idle_cycles_total) begin
      pu_tr = prio_update_trans_item::type_id::create("pu_idle", , get_full_name());
      start_item(pu_tr);
      if (!pu_tr.randomize() with {
            prio     == 4'h0;
            prio_id  == 5'd0;
            prio_upt == 1'b0;
          }) begin
        `uvm_error(get_full_name(), "Randomization failed for prio_update idle transaction")
      end
      finish_item(pu_tr);
    end
  endtask
endclass