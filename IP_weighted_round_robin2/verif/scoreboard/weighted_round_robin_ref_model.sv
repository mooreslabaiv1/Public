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
    parameter int N = 32;
    parameter int PRIORITY_W = 4;
    parameter int ID_BITS = $clog2(N);

    // ------------------------------------------------
    // LOCALPARAMS
    // ------------------------------------------------
    localparam int ST_WIDTH = PRIORITY_W + 1;
    localparam int ST_IDX_WIDTH = $clog2(ST_WIDTH);

    // ------------------------------------------------
    // INTERNAL STORAGE
    // ------------------------------------------------
    int credit[N-1:0];






    bit [PRIORITY_W-1:0] priority_vec[N];  // Per-requestor priorities
    bit [PRIORITY_W-1:0] cycle_label_counter_r;  // Weighted pointer
    bit [ID_BITS-1:0] index_ptr_r;  // Index pointer
    bit [N-1:0] sel_vec_mask_r;  // One-cycle partial mask

    // Scratch signals for “sterile” logic
    bit [ST_WIDTH-1:0] m_sterile_string;
    logic [ST_IDX_WIDTH-1:0] m_s_idx1, m_s_idx0;
    logic [ST_WIDTH-1:0] m_sterile_string_first_1, m_sterile_string_next_0;
    logic [ST_WIDTH-1:0] m_sterile_mask, m_ffs0_post_ss;
    bit m_next_0_is_sterile;
    logic [ST_WIDTH-1:0] m_sterile_inc_A, m_sterile_inc_B, m_sterile_inc_C, m_sterile_inc;

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

    ffs_onehot_out_t                 m_ffs_ret;
    bit              [        N-1:0] m_onehot_bits;
    bit                              m_found;
    bit              [$clog2(N)-1:0] m_shifted_idx;
    bit              [$clog2(N)-1:0] m_real_sel_idx;
    bit              [        N-1:0] m_sel_vec_1d;
    int                              m_grant_id;

    // ------------------------------------------------
    // UVM FACTORY REGISTRATION
    // ------------------------------------------------
    `uvm_component_utils_begin(weighted_round_robin_ref_model)
    `uvm_component_utils_end

    // ------------------------------------------------
    // CONSTRUCTOR
    // ------------------------------------------------
    function new(string name = "weighted_round_robin_ref_model", uvm_component parent = null);
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
            priority_vec[i] = 0;  // initial priority is all zeros
            credit[i] = 1;
        end

        cycle_label_counter_r = 'b1;
        sel_vec_mask_r        = '0;
        index_ptr_r           = '0;
    endfunction

    // ------------------------------------------------
    // update_priority(): set one requestor's priority
    // ------------------------------------------------
    function void update_priority(input bit [PRIORITY_W-1:0] p_value,
                                  input bit [ID_BITS-1:0] p_id);
        priority_vec[p_id] = p_value;
    endfunction

    // ------------------------------------------------
    // calc_grant(): produces the same grant ID as the RTL
    // ------------------------------------------------
    function int calc_grant(input bit [N-1:0] req, input bit ack);
        int found = 0;
        // Calculate grant_id for the given input
        for (int i = 0; i < N; i++) begin
            int index = (index_ptr_r + i) % N;

            $display("Index pointer = %d Credit[%d] = %d", index_ptr_r, index, credit[index]);
            // Check if this requestor is requesting and has credit.
            if ((req[index] == 1'b1) && (credit[index] != 0)) begin
                m_grant_id = index;

                if (ack) begin
                    // Use one credit
                    credit[index] = credit[index] - 1'b1;
                    // Increment index pointer
                    index_ptr_r   = (index + 1) % N;
                end
                $display("Index pointer = %d", index_ptr_r);
                found = 1;
                break;
            end
        end

        if (!found) begin
            for (int i = 0; i < N; i++) begin
                credit[i] = priority_vec[i] + 1;
            end
            m_grant_id = 0;
        end
        // Display
        for (int i = 0; i < N; i++) begin
            $display("%t TB: Credit[%d]= %d", $time, i, credit[i]);
        end
        return m_grant_id;
    endfunction


endclass : weighted_round_robin_ref_model

`endif  // WEIGHTED_ROUND_ROBIN_REF_MODEL__SV
