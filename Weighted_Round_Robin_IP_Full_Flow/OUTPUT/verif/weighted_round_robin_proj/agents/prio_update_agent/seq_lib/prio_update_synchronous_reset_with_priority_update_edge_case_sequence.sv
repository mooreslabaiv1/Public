
class prio_update_synchronous_reset_with_priority_update_edge_case_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_synchronous_reset_with_priority_update_edge_case_sequence)

  // Constrained-random knobs for phased updates around a reset boundary
  rand int unsigned pre_idle_cycles;        // initial idle cycles (prio_upt=0)
  rand int unsigned hold_high_cycles;       // cycles to hold prio_upt high across boundary (1-2)
  rand int unsigned reset_idle_cycles;      // simulate reset hold (inputs idle) >=8
  rand int unsigned post_gap_cycles;        // small gap before first post-reset update
  rand int unsigned periodic_updates;       // number of periodic updates after first post-reset
  rand int unsigned idle_between_updates;   // idle cycles between periodic updates

  rand bit use_min_first;                   // choose min priority for first update
  rand bit use_min_id_first;                // choose min id for first update (else max)

  constraint c_knobs {
    pre_idle_cycles        inside {[5:10]};
    hold_high_cycles       inside {[1:2]};
    reset_idle_cycles      inside {[8:12]};
    post_gap_cycles        inside {[0:2]};
    periodic_updates       inside {[6:16]};
    idle_between_updates   inside {[2:6]};
  }

  function new(string name = "prio_update_synchronous_reset_with_priority_update_edge_case_sequence");
    super.new(name);
  endfunction

  // Drive one cycle
  task drive_pu(logic [3:0] pr_v, logic [4:0] id_v, bit st);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == pr_v; prio_id == id_v; prio_upt == st; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item")
    end
    finish_item(pu_tr);
  endtask

  // Idle N cycles
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) drive_pu(4'h0, 5'd0, 1'b0);
  endtask

  // Random legal update
  task random_update();
    logic [3:0] pr_v;
    logic [4:0] id_v;
    void'(std::randomize(pr_v) with { pr_v inside {[0:15]}; });
    void'(std::randomize(id_v) with { id_v inside {[0:31]}; });
    drive_pu(pr_v, id_v, 1'b1);
  endtask

  virtual task body();
    int unsigned i;
    logic [3:0] first_prio, post_prio;
    logic [4:0] first_id, post_id;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update edge-case knobs")
    end

    // Determine directed first (pre/during reset boundary) and first post-reset updates
    first_prio = use_min_first ? 4'h0 : 4'hF;
    first_id   = use_min_id_first ? 5'd0 : 5'd31;
    post_prio  = use_min_first ? 4'hF : 4'h0;        // complement to hit min/max bins
    post_id    = use_min_id_first ? 5'd31 : 5'd0;    // complement to hit min/max ID bins

    // Phase-1: Normal operation (no updates)
    idle_n(pre_idle_cycles);

    // Phase-2: Initiate a legal priority update (intended "immediately before reset assertion")
    drive_pu(first_prio, first_id, 1'b1);

    // Phase-3: Hold prio_upt high for 1-2 cycles (simulate in-flight over reset boundary)
    for (i = 0; i < hold_high_cycles; i++) begin
      drive_pu(first_prio, first_id, 1'b1);
    end

    // Phase-4: Simulate reset assert-hold window by idling inputs for >=8 cycles
    idle_n(reset_idle_cycles);

    // Phase-5: Immediately after reset de-assertion, issue another legal update (accepted)
    idle_n(post_gap_cycles);
    drive_pu(post_prio, post_id, 1'b1);

    // Phase-6: Resume normal operation with periodic legal priority updates
    for (i = 0; i < periodic_updates; i++) begin
      // Either random update or directed min/max sweep occasionally
      if (($urandom_range(0,3) == 0)) begin
        // Directed sweep to ensure min/max coverage persists
        drive_pu(4'h0, $urandom_range(0,31), 1'b1);
        idle_n(idle_between_updates);
        drive_pu(4'hF, $urandom_range(0,31), 1'b1);
      end
      else begin
        random_update();
      end
      idle_n(idle_between_updates);
    end

    // Tail idle
    idle_n($urandom_range(4,8));
  endtask
endclass