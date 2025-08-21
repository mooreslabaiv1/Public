
`ifndef WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV
`define WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV

// -----------------------------------------------------------------------------
// Simple SystemVerilog reference model for Weighted Round Robin (WRR)
// Implemented as a UVM component and instantiated by the scoreboard.
// -----------------------------------------------------------------------------
class wrr_ref_model extends uvm_component;

  // Factory registration
  `uvm_component_utils(wrr_ref_model)

  // Parameters (fixed to match provided agents: N=32 requestors, PRIORITY_W=4)
  localparam int N = 32;
  localparam int PRIORITY_W = 4;
  localparam int ID_BITS = 5;

  // Internal state
  bit [PRIORITY_W-1:0] prio_reg [N];
  int unsigned credit_r [N];
  int unsigned pointer_r;

  // Constructor
  function new(string name = "wrr_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Initialize/reset state
  function void reset();
    int i;
    i = 0;
    for (i = 0; i < N; i++) begin
      prio_reg[i] = '0;
      credit_r[i] = 1; // per spec: credits initialized to 1
    end
    pointer_r = 0;
  endfunction : reset

  // Apply (optional) priority update
  function void apply_prio_update(bit        prio_upt,
                                  bit [4:0]  prio_id,
                                  bit [3:0]  prio);
    int idx;
    idx = prio_id;
    if (prio_upt && (idx >= 0) && (idx < N)) begin
      prio_reg[idx] = prio;
    end
  endfunction : apply_prio_update

  // One step of the WRR model. Given current inputs (req, ack, prio update),
  // produce expected outputs (gnt_w, gnt_id) and update internal state.
  function void step(bit [N-1:0] req,
                     bit         ack,
                     bit         prio_upt,
                     bit [4:0]   prio_id,
                     bit [3:0]   prio,
                     output bit [N-1:0] exp_gnt_w,
                     output bit [ID_BITS-1:0] exp_gnt_id);
    int k;
    int idx;
    int choose_idx;
    bit any_eligible;
    bit [N-1:0] eligible;

    // Apply priority update first (must take effect for refill in same cycle)
    apply_prio_update(prio_upt, prio_id, prio);

    // Build eligible mask: req && credit > 0
    eligible = '0;
    for (k = 0; k < N; k++) begin
      eligible[k] = (req[k] == 1'b1) && (credit_r[k] > 0);
    end

    // Scan from pointer to find first eligible
    any_eligible = (eligible != '0);
    choose_idx = -1;
    if (any_eligible) begin
      for (k = 0; k < N; k++) begin
        idx = (pointer_r + k) % N;
        if (eligible[idx]) begin
          choose_idx = idx;
          break;
        end
      end
    end

    // Drive outputs and update state
    exp_gnt_w = '0;
    exp_gnt_id = '0;
    if (choose_idx >= 0) begin
      exp_gnt_w[choose_idx] = 1'b1;
      exp_gnt_id = choose_idx[ID_BITS-1:0];

      // Advance pointer to next index for next arbitration
      pointer_r = (choose_idx + 1) % N;

      // Decrement credit only on ack
      if (ack) begin
        if (credit_r[choose_idx] > 0) begin
          credit_r[choose_idx] = credit_r[choose_idx] - 1;
        end
      end
    end
    else begin
      // No eligible -> no grant; refill credits to prio + 1
      for (k = 0; k < N; k++) begin
        credit_r[k] = prio_reg[k] + 1;
      end
      // pointer_r unchanged
    end
  endfunction : step

endclass : wrr_ref_model

// -----------------------------------------------------------------------------
// Scoreboard
// -----------------------------------------------------------------------------
class weighted_round_robin_scoreboard extends uvm_scoreboard;

  // TLM FIFOs (analysis fifos)
  uvm_tlm_analysis_fifo #(rr_request_trans_item)        weighted_round_robin_rr_request_agent_fifo;
  uvm_tlm_analysis_fifo #(rr_grant_monitor_trans_item)  weighted_round_robin_rr_grant_monitor_agent_fifo;
  uvm_tlm_analysis_fifo #(prio_update_trans_item)       weighted_round_robin_prio_update_agent_fifo;
  uvm_tlm_analysis_fifo #(clk_rst_trans_item)           weighted_round_robin_clk_rst_agent_fifo;

  // Register with factory
  `uvm_component_utils(weighted_round_robin_scoreboard)

  // Reference model instance
  wrr_ref_model m_ref;

  // Internal queues to align per-cycle inputs with observed DUT grant outputs
  rr_request_trans_item  req_q[$];
  prio_update_trans_item prio_q[$];

  // Reset track
  bit in_reset;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "weighted_round_robin_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //*****************************************************************************
  // Build Phase
  //*****************************************************************************
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    weighted_round_robin_rr_request_agent_fifo       = new("weighted_round_robin_rr_request_agent_fifo", this);
    weighted_round_robin_rr_grant_monitor_agent_fifo = new("weighted_round_robin_rr_grant_monitor_agent_fifo", this);
    weighted_round_robin_prio_update_agent_fifo      = new("weighted_round_robin_prio_update_agent_fifo", this);
    weighted_round_robin_clk_rst_agent_fifo          = new("weighted_round_robin_clk_rst_agent_fifo", this);

    // Create the reference model
    m_ref = wrr_ref_model::type_id::create("m_ref", this);
    if (m_ref == null) begin
      `uvm_fatal(get_full_name(), "Failed to create WRR reference model")
    end

    // Initialize state
    in_reset = 0;
    m_ref.reset();
  endfunction : build_phase

  //******************************************************************************
  // Connect Phase
  //******************************************************************************
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************  
  task run_phase(uvm_phase phase);
    fork
      process_rr_request_agent_fifo();
      process_rr_grant_monitor_agent_fifo();
      process_prio_update_agent_fifo();
      process_clk_rst_agent_fifo();
    join_none
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************  

  // Collect request/ack inputs
  task process_rr_request_agent_fifo();
    rr_request_trans_item tr;
    forever begin
      tr = null;
      weighted_round_robin_rr_request_agent_fifo.get(tr);
      if (tr != null) begin
        req_q.push_back(tr);
        `uvm_info(get_full_name(), $sformatf("REQ/ACK RX\n%s", tr.sprint()), UVM_HIGH)
      end
    end
  endtask : process_rr_request_agent_fifo

  // Collect prio updates
  task process_prio_update_agent_fifo();
    prio_update_trans_item tr;
    forever begin
      tr = null;
      weighted_round_robin_prio_update_agent_fifo.get(tr);
      if (tr != null) begin
        prio_q.push_back(tr);
        `uvm_info(get_full_name(), $sformatf("PRIO UPDATE RX\n%s", tr.sprint()), UVM_HIGH)
      end
    end
  endtask : process_prio_update_agent_fifo

  // Process grants, check against reference model
  task process_rr_grant_monitor_agent_fifo();
    rr_grant_monitor_trans_item gtr;
    rr_request_trans_item       rq;
    prio_update_trans_item      pu;
    bit [31:0]                  req_val;
    bit                         ack_val;
    bit                         prio_upt_val;
    bit [3:0]                   prio_val;
    bit [4:0]                   prio_id_val;
    bit [31:0]                  exp_gnt_w;
    bit [4:0]                   exp_gnt_id;
    int                         set_bits;
    int                         i;
    forever begin
      gtr = null;
      rq  = null;
      pu  = null;
      req_val = '0;
      ack_val = '0;
      prio_upt_val = 1'b0;
      prio_val = '0;
      prio_id_val = '0;
      exp_gnt_w = '0;
      exp_gnt_id = '0;
      set_bits = 0;
      i = 0;

      weighted_round_robin_rr_grant_monitor_agent_fifo.get(gtr);
      if (gtr == null) begin
        continue;
      end

      `uvm_info(get_full_name(), $sformatf("GRANT RX\n%s", gtr.sprint()), UVM_HIGH)

      // Basic structural check: one-hot or zero
      set_bits = 0;
      for (i = 0; i < 32; i++) begin
        if (gtr.gnt_w[i]) set_bits++;
      end
      if (!(set_bits == 1 || set_bits == 0)) begin
        `uvm_error(get_full_name(), $sformatf("gnt_w is not one-hot (or zero). gnt_w=%0h set_bits=%0d", gtr.gnt_w, set_bits))
      end
      if (set_bits == 1) begin
        if (gtr.gnt_id > 31) begin
          `uvm_error(get_full_name(), $sformatf("gnt_id out of range: %0d", gtr.gnt_id))
        end
        else if (gtr.gnt_w[gtr.gnt_id] !== 1'b1) begin
          `uvm_error(get_full_name(), $sformatf("gnt_id (%0d) does not match one-hot gnt_w (%0h)", gtr.gnt_id, gtr.gnt_w))
        end
      end

      // During reset, no grant should be asserted
      if (in_reset) begin
        if (gtr.gnt_w != '0) begin
          `uvm_error(get_full_name(), $sformatf("Grant asserted during reset! gnt_w=%0h gnt_id=%0d", gtr.gnt_w, gtr.gnt_id))
        end
        continue;
      end

      // Pop next request/ack for this cycle
      if (req_q.size() > 0) begin
        rq = req_q.pop_front();
        req_val = rq.req;
        ack_val = rq.ack;
      end
      else begin
        // If we cannot align, assume idle inputs
        `uvm_warning(get_full_name(), "No request transaction available for current grant; assuming req=0, ack=0")
        req_val = '0;
        ack_val = 1'b0;
      end

      // Optionally consume at most one prio update for this cycle
      if (prio_q.size() > 0) begin
        pu = prio_q.pop_front();
        prio_upt_val = pu.prio_upt;
        prio_val     = pu.prio;
        prio_id_val  = pu.prio_id;
      end
      else begin
        prio_upt_val = 1'b0;
        prio_val     = '0;
        prio_id_val  = '0;
      end

      // Step the reference model and compare
      m_ref.step(req_val, ack_val, prio_upt_val, prio_id_val, prio_val, exp_gnt_w, exp_gnt_id);

      if ((gtr.gnt_w !== exp_gnt_w) || (gtr.gnt_id !== exp_gnt_id)) begin
        `uvm_error(get_full_name(),
          $sformatf("Grant mismatch. DUT: gnt_w=%0h gnt_id=%0d | EXP: gnt_w=%0h gnt_id=%0d | req=%0h ack=%0b prio_upt=%0b prio_id=%0d prio=%0h",
                    gtr.gnt_w, gtr.gnt_id, exp_gnt_w, exp_gnt_id, req_val, ack_val, prio_upt_val, prio_id_val, prio_val))
      end
      else begin
        `uvm_info(get_full_name(),
          $sformatf("Grant match. gnt_w=%0h gnt_id=%0d", gtr.gnt_w, gtr.gnt_id), UVM_MEDIUM)
      end
    end
  endtask : process_rr_grant_monitor_agent_fifo

  // Handle reset notifications
  task process_clk_rst_agent_fifo();
    clk_rst_trans_item tr;
    forever begin
      tr = null;
      weighted_round_robin_clk_rst_agent_fifo.get(tr);
      if (tr == null) begin
        continue;
      end

      `uvm_info(get_full_name(), $sformatf("RESET EVENT RX\n%s", tr.sprint()), UVM_LOW)

      if (tr.reset_asserted) begin
        in_reset = 1'b1;
        m_ref.reset();
        req_q.delete();
        prio_q.delete();
      end
      if (tr.reset_deasserted) begin
        in_reset = 1'b0;
      end
    end
  endtask : process_clk_rst_agent_fifo

endclass : weighted_round_robin_scoreboard
`endif  // WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV