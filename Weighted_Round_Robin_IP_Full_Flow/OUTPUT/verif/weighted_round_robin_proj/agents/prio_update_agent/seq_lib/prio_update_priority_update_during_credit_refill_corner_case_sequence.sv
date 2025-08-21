
class prio_update_priority_update_during_credit_refill_corner_case_sequence extends prio_update_base_seq;
  `uvm_object_utils(prio_update_priority_update_during_credit_refill_corner_case_sequence)

  // Shared configuration keys with rr_request sequence
  localparam string CFG_PRE_IDLE = "refill_pre_idle_cycles";
  localparam string CFG_ZERO_LEN = "refill_zero_len";
  localparam string CFG_ONES_LEN = "refill_ones_len";

  // Local copies (may be overridden by rr_request via uvm_config_db)
  rand int unsigned pre_idle_cycles;
  rand int unsigned zero_len;
  rand int unsigned ones_len;

  constraint c_knobs {
    pre_idle_cycles inside {[6:12]};
    zero_len        inside {[1:3]};
    ones_len        inside {[2:5]};
  }

  function new(string name = "prio_update_priority_update_during_credit_refill_corner_case_sequence");
    super.new(name);
  endfunction

  // Emit one prio_update transaction
  task drive_pu(logic [3:0] pr_v, logic [4:0] id_v, bit strobe);
    prio_update_trans_item pu_tr;
    pu_tr = prio_update_trans_item::type_id::create("pu_tr", , get_full_name());
    start_item(pu_tr);
    if (!pu_tr.randomize() with { prio == pr_v; prio_id == id_v; prio_upt == strobe; }) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update_trans_item in drive_pu()")
    end
    finish_item(pu_tr);
  endtask

  // Idle N cycles on priority interface (no update)
  task idle_n(int unsigned n);
    for (int unsigned i = 0; i < n; i++) begin
      drive_pu(4'h0, 5'd0, 1'b0);
    end
  endtask

  // For a given ID and target priority, assert prio_upt exactly on the last cycle of the zero window
  task program_on_refill(int unsigned id, logic [3:0] pr_val);
    // zero window: last zero cycle contains the strobe for updating priority
    if (zero_len > 0) begin
      // first zero_len-1 cycles: no update
      idle_n(zero_len-1);
      // last zero cycle: perform priority update
      drive_pu(pr_val, id[4:0], 1'b1);
    end
    else begin
      // degenerate case: directly strobe (shouldn't happen due to constraint)
      drive_pu(pr_val, id[4:0], 1'b1);
    end

    // ones window (requestor side drives req=all 1's); keep prio_upt low
    idle_n(ones_len);
  endtask

  virtual task body();
    // Try to pick up alignment knobs published by rr_request sequence
    int tmp;
    void'(uvm_config_db#(int)::get(null, "*", CFG_PRE_IDLE, tmp)); if (tmp) pre_idle_cycles = tmp;
    void'(uvm_config_db#(int)::get(null, "*", CFG_ZERO_LEN, tmp)); if (tmp) zero_len        = tmp;
    void'(uvm_config_db#(int)::get(null, "*", CFG_ONES_LEN, tmp)); if (tmp) ones_len        = tmp;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize prio_update knobs")
    end

    // Publish (idempotent) so both agents converge even if this seq starts first
    uvm_config_db#(int)::set(null, "*", CFG_PRE_IDLE, pre_idle_cycles);
    uvm_config_db#(int)::set(null, "*", CFG_ZERO_LEN, zero_len);
    uvm_config_db#(int)::set(null, "*", CFG_ONES_LEN, ones_len);

    // Pre-idle alignment
    idle_n(pre_idle_cycles);

    // Pass 0: set each requestor to minimum priority (0) on the refill cycle
    for (int unsigned id = 0; id < 32; id++) begin
      program_on_refill(id, 4'h0);
    end

    // Small neutral gap to separate passes
    idle_n($urandom_range(3,7));

    // Pass 1: set each requestor to maximum priority (15) on the refill cycle
    for (int unsigned id = 0; id < 32; id++) begin
      program_on_refill(id, 4'hF);
    end

    // Tail idle
    idle_n($urandom_range(4,8));
  endtask
endclass