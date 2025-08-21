
class prio_update_reset_deasserted_mid_cycle_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_reset_deasserted_mid_cycle_sequence)

  // Constrained-random knobs for post-reset priority updates
  rand int unsigned idle_cycles_after_reset;
  rand int unsigned update_window_cycles;
  rand int unsigned update_strobe_pct; // how often to assert prio_upt
  rand bit          include_minmax_sweep;

  constraint c_knobs {
    idle_cycles_after_reset inside {[3:8]};
    update_window_cycles    inside {[80:160]};
    update_strobe_pct       inside {[20:50]};
  }

  function new(string name = "prio_update_reset_deasserted_mid_cycle_sequence");
    super.new(name);
  endfunction

  task drive_pu_cycle(bit strobe, logic [4:0] id_v, logic [3:0] pr_v);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr",,get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio_upt == strobe; prio_id == id_v; prio == pr_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Idle N cycles (no update)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_pu_cycle(1'b0, 5'd0, 4'h0);
    end
  endtask

  // Random legal update
  task random_update();
    logic [4:0] id_v;
    logic [3:0] pr_v;
    void'(std::randomize(id_v) with { id_v inside {[0:31]}; });
    void'(std::randomize(pr_v) with { pr_v inside {[0:15]}; });
    drive_pu_cycle(1'b1, id_v, pr_v);
  endtask

  virtual task body();
    int unsigned i;
    bit st;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update knobs")
    end

    // Post-reset settle
    idle_n(idle_cycles_after_reset);

    // Optional directed min/max sweep to bound behavior right after mid-cycle reset release
    void'(std::randomize(include_minmax_sweep) with { include_minmax_sweep dist {1 := 1, 0 := 3}; });
    if (include_minmax_sweep) begin
      drive_pu_cycle(1'b1, 5'd0,  4'h0);
      drive_pu_cycle(1'b1, 5'd31, 4'hF);
      idle_n($urandom_range(1,3));
    end

    // Randomized update window
    for (i = 0; i < update_window_cycles; i++) begin
      st = ($urandom_range(0,99) < update_strobe_pct);
      if (st) random_update();
      else    drive_pu_cycle(1'b0, 5'd0, 4'h0);
    end

    // Tail idle
    idle_n($urandom_range(4,8));
  endtask
endclass