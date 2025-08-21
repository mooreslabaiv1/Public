
class prio_update_basic_arbitration_grant_and_latency_test_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_basic_arbitration_grant_and_latency_test_sequence)

  // Generate mostly idle prio_upt, with optional few randomized updates
  rand int unsigned idle_cycles_initial;
  rand int unsigned num_updates;
  rand int unsigned idle_between_updates_min;
  rand int unsigned idle_between_updates_max;

  constraint c_knobs {
    idle_cycles_initial inside {[10:20]};
    num_updates inside {[0:4]};
    idle_between_updates_min inside {[2:5]};
    idle_between_updates_max inside {[6:12]};
    idle_between_updates_max >= idle_between_updates_min;
  }

  function new(string name = "prio_update_basic_arbitration_grant_and_latency_test_sequence");
    super.new(name);
  endfunction

  // Drive one cycle on prio interface
  task drive_pu_cycle(logic [3:0] prio_v, logic [4:0] prio_id_v, logic prio_upt_v);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr",,get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with {
          prio     == prio_v;
          prio_id  == prio_id_v;
          prio_upt == prio_upt_v;
        }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Idle cycles: prio_upt=0
  task idle_n(int unsigned n);
    repeat (n) drive_pu_cycle(4'h0, 5'd0, 1'b0);
  endtask

  virtual task body();
    int unsigned u, gap;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Initial idle
    idle_n(idle_cycles_initial);

    // Optional updates
    for (u = 0; u < num_updates; u++) begin
      logic [4:0] id;
      logic [3:0] pr;
      void'(std::randomize(id) with { id inside {[0:31]}; });
      void'(std::randomize(pr) with { pr inside {[0:15]}; });

      // Single-cycle strobe
      drive_pu_cycle(pr, id, 1'b1);

      // Idle gap following update
      void'(std::randomize(gap) with { gap inside {[idle_between_updates_min:idle_between_updates_max]}; });
      idle_n(gap);
    end

    // Tail idle
    idle_n($urandom_range(8,16));
  endtask
endclass