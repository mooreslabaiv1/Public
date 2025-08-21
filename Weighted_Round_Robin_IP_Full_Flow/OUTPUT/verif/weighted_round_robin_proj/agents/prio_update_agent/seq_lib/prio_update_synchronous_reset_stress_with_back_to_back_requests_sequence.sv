


class prio_update_synchronous_reset_stress_with_back_to_back_requests_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_synchronous_reset_stress_with_back_to_back_requests_sequence)

  // Knobs
  rand int unsigned pre_active_cycles;  // 5-10 cycles pre or idle window
  rand int unsigned pseudo_rst_cycles;  // fixed 4 cycles "during reset"
  rand int unsigned update_window_cycles; // >=1000 to align with request stress
  rand int unsigned update_strobe_pct; // percentage likelihood (0..100) that prio_upt is asserted in a cycle

  constraint c_knobs {
    pre_active_cycles inside {[5:10]};
    pseudo_rst_cycles == 4;
    update_window_cycles inside {[1000:1500]};
    update_strobe_pct inside {[15:40]}; // 15-40% updates to stress runtime priority changes
  }

  function new(string name = "prio_update_synchronous_reset_stress_with_back_to_back_requests_sequence");
    super.new(name);
  endfunction

  // Drive one cycle on priority interface
  task drive_prio_cycle(bit strobe);
    prio_update_trans_item pu_tr;
    logic [4:0]  id_v;
    logic [3:0]  pr_v;
    bit          force_edge;
    bit          pick_max;

    // Ensure IDs explore min/max and random range
    if (!std::randomize(id_v) with { id_v inside {[0:31]}; }) id_v = 5'd0;
    if (!std::randomize(pr_v) with { pr_v inside {[0:15]}; }) pr_v = 4'h0;

    // Occasionally force min/max ID explicitly
    void'(std::randomize(force_edge) with { force_edge dist {1 := 1, 0 := 9}; });
    if (force_edge) begin
      void'(std::randomize(pick_max));
      id_v = pick_max ? 5'd31 : 5'd0;
    end

    pu_tr = prio_update_trans_item::type_id::create("pu_tr",,get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == pr_v; prio_id == id_v; prio_upt == strobe; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  virtual task body();
    // Declarations at the beginning of the task as per coding guidelines
    bit st;
    int i;
    int r;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update sequence knobs")
    end

    // Pre-active randomized cycles with mostly no updates
    repeat (pre_active_cycles) begin
      drive_prio_cycle(1'b0);
    end

    // Pseudo "during reset" cycles (driver may idle due to rst); still generate items
    repeat (pseudo_rst_cycles) begin
      // Randomize strobe low/high to cross coverage expectations
      void'(std::randomize(st) with { st dist {1 := 1, 0 := 3}; });
      drive_prio_cycle(st);
    end

    // Long update window with randomized strobes
    for (i = 0; i < update_window_cycles; i++) begin
      void'(std::randomize(r) with { r inside {[0:99]}; });
      drive_prio_cycle( (r < update_strobe_pct) );
    end
  endtask
endclass