`ifndef WEIGHTED_ROUND_ROBIN_REF_MODEL__SV
`define WEIGHTED_ROUND_ROBIN_REF_MODEL__SV

import uvm_pkg::*;

// --------------------------------------------------------------------------
// Weighted Round Robin Reference Model (Fully Fixed)
// --------------------------------------------------------------------------
class weighted_round_robin_ref_model extends uvm_component;

  // ------------------------------------------------
  // PARAMETERS
  // ------------------------------------------------
  parameter int N           = 32;
  parameter int PRIORITY_W  = 4;
  parameter int ID_BITS     = $clog2(N);

  // ------------------------------------------------
  // LOCALPARAMS
  // ------------------------------------------------
  localparam int ST_WIDTH     = PRIORITY_W + 1;  
  localparam int ST_IDX_WIDTH = $clog2(ST_WIDTH); 

  // ------------------------------------------------
  // INTERNAL STORAGE
  // ------------------------------------------------
  bit [PRIORITY_W-1:0] priority_vec [N];  // Per-requestor priorities
  bit [PRIORITY_W-1:0] cycle_label_counter_r; // Weighted pointer
  bit [ID_BITS-1:0]    index_ptr_r;           // Index pointer
  bit [N-1:0]          sel_vec_mask_r;        // One-cycle partial mask

  // Scratch signals for “sterile” logic
  bit [ST_WIDTH-1:0]        m_sterile_string;
  logic [ST_IDX_WIDTH-1:0]  m_s_idx1, m_s_idx0;
  logic [ST_WIDTH-1:0]      m_sterile_string_first_1, m_sterile_string_next_0;
  logic [ST_WIDTH-1:0]      m_sterile_mask, m_ffs0_post_ss;
  bit                       m_next_0_is_sterile;
  logic [ST_WIDTH-1:0]      m_sterile_inc_A, m_sterile_inc_B, m_sterile_inc_C, m_sterile_inc;

  // Weighted pointer addition
  bit [PRIORITY_W-1:0] m_raw_next;
  bit [PRIORITY_W-1:0] m_cycle_label_counter_w;

  // Round-robin request signals
  bit [N-1:0] m_round_req;
  bit [N-1:0] m_raw_sel_vec;
  bit [N-1:0] m_shifted_sel_vec;

  typedef struct packed {
    bit [N-1:0]         onehot;
    bit                 found;
    bit [$clog2(N)-1:0] idx;
  } ffs_onehot_out_t;

  ffs_onehot_out_t   m_ffs_ret;
  bit [N-1:0]        m_onehot_bits;
  bit                m_found;
  bit [$clog2(N)-1:0] m_shifted_idx;
  bit [$clog2(N)-1:0] m_real_sel_idx;
  bit [N-1:0]        m_sel_vec_1d;
  int                m_grant_id;

  // ------------------------------------------------
  // UVM FACTORY REGISTRATION
  // ------------------------------------------------
  `uvm_component_utils_begin(weighted_round_robin_ref_model)
  `uvm_component_utils_end

  // ------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------
  function new(string name="weighted_round_robin_ref_model", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // ------------------------------------------------
  // build_phase
  // ------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset();
  endfunction

  // ------------------------------------------------
  // reset(): Mimic the RTL's reset
  // ------------------------------------------------
  function void reset();
    // Priority defaults to all 1's
    for (int i = 0; i < N; i++) begin
      priority_vec[i] = {PRIORITY_W{1'b1}};
    end

    cycle_label_counter_r = 'b1;
    sel_vec_mask_r        = '0;
    index_ptr_r           = '0;
  endfunction

  // ------------------------------------------------
  // update_priority(): set one requestor's priority
  // ------------------------------------------------
  function void update_priority(
    input bit [PRIORITY_W-1:0] p_value,
    input bit [ID_BITS-1:0]    p_id
  );
    priority_vec[p_id] = p_value;
  endfunction

  // ------------------------------------------------
  // calc_grant(): produces the same grant ID as the RTL
  // ------------------------------------------------
  function int calc_grant(input bit [N-1:0] req, input bit ack);

    // 1) Build “sterile” string
    m_sterile_string = '0;
    for (int p = 0; p < PRIORITY_W; p++) begin
      for (int i = 0; i < N; i++) begin
        if (req[i] && priority_vec[i][p]) begin
          m_sterile_string[p] = 1'b1;
        end
      end
    end

    // 2) Indices for first '1' and first '0'
    m_s_idx1 = ffs_index(m_sterile_string, 1'b0);
    m_s_idx0 = ffs_index(m_sterile_string, 1'b1);

    m_sterile_string_first_1 = extend_idx_to_st_width(m_s_idx1);
    m_sterile_string_next_0  = extend_idx_to_st_width(m_s_idx0);
    m_sterile_mask           = m_sterile_string_first_1 - 'b1;
    m_ffs0_post_ss           = {1'b0, cycle_label_counter_r} | m_sterile_mask;
    m_next_0_is_sterile      = |((~m_sterile_string) & m_sterile_string_next_0);

    m_sterile_inc_A = {1'b0, m_sterile_mask[PRIORITY_W-1:0]}
                      ^ (cycle_label_counter_r & m_sterile_mask[PRIORITY_W-1:0]);
    m_sterile_inc_B = 'b1;
    m_sterile_inc_C = m_next_0_is_sterile ? m_sterile_string_first_1 : 'b0;
    m_sterile_inc   = m_sterile_inc_A + m_sterile_inc_B + m_sterile_inc_C;

    // Weighted pointer addition
    m_raw_next = cycle_label_counter_r + m_sterile_inc[PRIORITY_W-1:0];
    m_cycle_label_counter_w = (m_raw_next == 0) ? 'b1 : m_raw_next;

    // 3) Round request formation
    for (int i = 0; i < N; i++) begin
      // Weighted approach: only consider requestor i if bits of priority & pointer intersect
      m_round_req[i] = req[i] && |(priority_vec[i] & cycle_label_counter_r);
    end

    // 4) raw_sel_vec => rotate => ffs_onehot
    m_raw_sel_vec     = (~sel_vec_mask_r) & m_round_req;
    m_shifted_sel_vec = rotate_vec(m_raw_sel_vec, index_ptr_r);
    m_ffs_ret         = ffs_onehot(m_shifted_sel_vec);

    m_onehot_bits = m_ffs_ret.onehot;
    m_found       = m_ffs_ret.found;
    m_shifted_idx = m_ffs_ret.idx;

    m_real_sel_idx = (index_ptr_r + m_shifted_idx) % N;
    m_sel_vec_1d   = '0;
    if (m_found) begin
      m_sel_vec_1d[m_real_sel_idx] = 1'b1;
    end

    // --- Match the RTL update rules exactly ---
    // (1) Weighted pointer updates any time ack=1
    // (2) sel_vec_mask is cleared if ack=1, else accumulates
    if (ack) begin
      cycle_label_counter_r = m_cycle_label_counter_w;
      sel_vec_mask_r        = '0;
    end
    else begin
      sel_vec_mask_r = sel_vec_mask_r | m_sel_vec_1d;
    end

    // Index pointer only increments if (m_found && ack)
    if (m_found && ack) begin
      index_ptr_r = index_ptr_r + 1;
    end

    // 5) Return gnt_id
    // The RTL sets gnt_id=0 if no requestor was found
    m_grant_id = 0;
    if (m_found)
      m_grant_id = m_real_sel_idx;

    return m_grant_id;
  endfunction

  // --------------------------------------------------------------------------
  // HELPER FUNCTIONS
  // --------------------------------------------------------------------------
  // 1) ffs_index: index of first set (or clear) bit
  function automatic logic [ST_IDX_WIDTH-1:0] ffs_index(
    input logic [ST_WIDTH-1:0] x,
    input bit                  find_zero
  );
    logic [ST_IDX_WIDTH-1:0] idx = '0;
    for (int i = 0; i < ST_WIDTH; i++) begin
      if ((!find_zero && x[i]) || (find_zero && !x[i])) begin
        idx = i;
        break;
      end
    end
    return idx;
  endfunction

  // 2) extend_idx_to_st_width
  function automatic logic [ST_WIDTH-1:0] extend_idx_to_st_width(
    input logic [ST_IDX_WIDTH-1:0] idx
  );
    logic [ST_WIDTH-1:0] temp = '0;
    temp = idx;
    return temp;
  endfunction

  // 3) rotate_vec
  function automatic bit [N-1:0] rotate_vec(
    input bit [N-1:0]         in_vec,
    input bit [$clog2(N)-1:0] start
  );
    bit [N-1:0] out_vec = '0;
    for (int i=0; i<N; i++) begin
      int actual_i = (start + i) % N;
      out_vec[i]   = in_vec[actual_i];
    end
    return out_vec;
  endfunction

  // 4) ffs_onehot: returns {onehot, found, idx} from the first set bit
  function automatic ffs_onehot_out_t ffs_onehot(
    input bit [N-1:0] bits
  );
    ffs_onehot_out_t ret;
    ret.onehot = '0;
    ret.found  = 1'b0;
    ret.idx    = '0;
    for (int i=0; i<N; i++) begin
      if (!ret.found && bits[i]) begin
        ret.found     = 1'b1;
        ret.idx       = i;
        ret.onehot[i] = 1'b1;
      end
    end
    return ret;
  endfunction

endclass : weighted_round_robin_ref_model

`endif // WEIGHTED_ROUND_ROBIN_REF_MODEL__SV
