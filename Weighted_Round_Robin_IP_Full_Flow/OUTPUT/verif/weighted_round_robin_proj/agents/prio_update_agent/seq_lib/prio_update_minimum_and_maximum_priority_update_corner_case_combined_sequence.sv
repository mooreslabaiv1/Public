
class prio_update_minimum_and_maximum_priority_update_corner_case_combined_sequence extends prio_update_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the prio_update_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(prio_update_minimum_and_maximum_priority_update_corner_case_combined_sequence)

  // Knobs
  rand int unsigned pre_init_gap;             // idle cycles before initializing to mid-range
  rand int unsigned init_gap_min;             // min gap between initial programming updates
  rand int unsigned init_gap_max;             // max gap between initial programming updates
  rand int unsigned wait_after_min_min;       // min cycles to wait after setting prio=0 per ID
  rand int unsigned wait_after_min_max;       // max cycles to wait after setting prio=0 per ID
  rand int unsigned wait_after_max_min;       // min cycles to wait after setting prio=F per ID
  rand int unsigned wait_after_max_max;       // max cycles to wait after setting prio=F per ID
  rand int unsigned dyn_update_burst_cnt;     // additional random min/max updates during operation
  rand int unsigned dyn_gap_min;              // min idle gap between dynamic updates
  rand int unsigned dyn_gap_max;              // max idle gap between dynamic updates
  rand bit          final_mix_enable;         // enable final mixed min/max programming across IDs

  constraint c_knobs {
    pre_init_gap         inside {[2:6]};
    init_gap_min         inside {[0:2]};
    init_gap_max         inside {[1:4]};
    init_gap_max >= init_gap_min;

    wait_after_min_min   inside {[2:5]};
    wait_after_min_max   inside {[6:10]};
    wait_after_min_max  >= wait_after_min_min;

    wait_after_max_min   inside {[2:5]};
    wait_after_max_max   inside {[6:10]};
    wait_after_max_max  >= wait_after_max_min;

    dyn_update_burst_cnt inside {[24:64]};
    dyn_gap_min          inside {[0:2]};
    dyn_gap_max          inside {[1:4]};
    dyn_gap_max >= dyn_gap_min;
  }

  function new(string name = "prio_update_minimum_and_maximum_priority_update_corner_case_combined_sequence");
    super.new(name);
  endfunction

  // Drive one cycle on priority interface
  task drive_update(logic [3:0] pr_v, logic [4:0] id_v, bit strobe);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == pr_v; prio_id == id_v; prio_upt == strobe; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item in drive_update()")
    end
    finish_item(pu_tr);
  endtask

  // Idle N cycles (no update)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_update(4'h0, 5'd0, 1'b0);
    end
  endtask

  virtual task body();
    int unsigned i, gap, split, id_sel;
    int unsigned wait_min, wait_max, dwell;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update min/max combined knobs")
    end

    // Step-3: Initialize all requestors with mid-range priority (8)
    idle_n(pre_init_gap);
    for (i = 0; i < 32; i++) begin
      drive_update(4'h8, i[4:0], 1'b1);
      void'(std::randomize(gap) with { gap inside {[init_gap_min:init_gap_max]}; });
      idle_n(gap);
    end

    // Step-6 per requestor:
    // (a) Set priority to minimum (0)
    // (b) Wait some cycles (ack pulses happen in rr_request)
    // (c) Set priority to maximum (F)
    // (d) Wait again
    for (i = 0; i < 32; i++) begin
      // a) update to min
      drive_update(4'h0, i[4:0], 1'b1);
      // b) randomized dwell to allow one or more grants/acks
      void'(std::randomize(dwell) with { dwell inside {[wait_after_min_min:wait_after_min_max]}; });
      idle_n(dwell);

      // c) update to max
      drive_update(4'hF, i[4:0], 1'b1);
      // d) dwell again
      void'(std::randomize(dwell) with { dwell inside {[wait_after_max_min:wait_after_max_max]}; });
      idle_n(dwell);
    end

    // Step-8/9: Additional dynamic updates during active operation to stress runtime behavior
    for (i = 0; i < dyn_update_burst_cnt; i++) begin
      void'(std::randomize(id_sel) with { id_sel inside {[0:31]}; });
      // Randomly choose min or max
      if ($urandom_range(0,1)) drive_update(4'h0, id_sel[4:0], 1'b1);
      else                     drive_update(4'hF, id_sel[4:0], 1'b1);
      void'(std::randomize(gap) with { gap inside {[dyn_gap_min:dyn_gap_max]}; });
      idle_n(gap);
    end

    // Step-10: Exercise combinations (e.g., half min, half max) if enabled
    if (final_mix_enable) begin
      split = $urandom_range(8, 24);
      // set first segment to min
      for (i = 0; i < split; i++) begin
        drive_update(4'h0, i[4:0], 1'b1);
        idle_n($urandom_range(0,1));
      end
      // set remaining to max
      for (i = split; i < 32; i++) begin
        drive_update(4'hF, i[4:0], 1'b1);
        idle_n($urandom_range(0,1));
      end
    end

    // Tail idle
    idle_n($urandom_range(6,12));
  endtask
endclass