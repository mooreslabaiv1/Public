module weighted_round_robin #(
    parameter int N           = 32,
    parameter int PRIORITY_W  = 4,
    parameter int ID_BITS     = $clog2(N)
) (
    //------------------------------------------------
    // Inputs
    //------------------------------------------------
    input  logic                     clk,
    input  logic                     rst,

    // Request signals
    input  logic [N-1:0]            req,
    // Acknowledge for pointer increments
    input  logic                     ack,

    //------------------------------------------------
    // Outputs
    //------------------------------------------------
    output logic [N-1:0]            gnt_w,
    output logic [ID_BITS-1:0]      gnt_id,

    //------------------------------------------------
    // Priority Update Interface
    //------------------------------------------------
    input  logic [PRIORITY_W-1:0]   prio,
    input  logic [ID_BITS-1:0]      prio_id,
    input  logic                     prio_upt
);

  //--------------------------------------------------
  // Internal Type & Signal Declarations
  //--------------------------------------------------
  typedef logic [PRIORITY_W-1:0] priority_t;
  // “sterile_t” is (PRIORITY_W+1) bits:
  typedef logic [PRIORITY_W:0] sterile_t;

  // Priority storage
  typedef struct packed {
    priority_t [N-1:0] p;
  } priority_vec_t;

  priority_vec_t priority_vec_r, priority_vec_w;

  // Weighted pointer
  logic [PRIORITY_W-1:0] cycle_label_counter_r, cycle_label_counter_w;
  logic                  cycle_label_counter_en;
  logic [PRIORITY_W-1:0] raw_next;

  // “Sterile” logic signals
  sterile_t sterile_string;
  
  // We'll store the ffs “index” in smaller signals:
  logic [$clog2(PRIORITY_W+1)-1:0] sterile_string_first_1_idx; 
  logic [$clog2(PRIORITY_W+1)-1:0] sterile_string_next_0_idx;

  // Then expand them to 5 bits (if PRIORITY_W=4) for arithmetic:
  logic [PRIORITY_W:0] sterile_string_first_1; 
  logic [PRIORITY_W:0] sterile_string_next_0;  

  sterile_t sterile_mask, ffs0_post_ss;
  sterile_t sterile_inc_A, sterile_inc_B, sterile_inc_C, sterile_inc;
  logic     next_0_is_sterile;

  // Request signals (before rotation & masking)
  logic [N-1:0] round_req;

  // For final selection
  logic [N-1:0] sel_vec_mask_r, sel_vec_mask_w;
  logic         sel_vec_mask_en;
  logic [N-1:0] sel_vec_1d;
  logic         sel_vec_found;
  logic [ID_BITS-1:0] sel_vec_idx;
  logic sel_vec_empty;

  // Priority vector enable
  logic priority_vec_en;

  // A second pointer for rotating among requestors
  logic [ID_BITS-1:0] index_ptr_r, index_ptr_w;
  logic               index_ptr_en;

  //--------------------------------------------------
  // 1) Helper function: rotate_vec
  //--------------------------------------------------
  // Rotates in_vec so that index_ptr is "bit 0" in the returned vector.
  function automatic logic [N-1:0] rotate_vec(
    input logic [N-1:0] in_vec,
    input logic [ID_BITS-1:0] start_index
  );
    logic [N-1:0] out_vec;
    for (int i = 0; i < N; i++) begin
      int actual_i = (start_index + i) % N;
      out_vec[i] = in_vec[actual_i];
    end
    return out_vec;
  endfunction

  //--------------------------------------------------
  // Priority Vector Update (Combinational)
  //--------------------------------------------------
  always_comb begin
    // Default: no update
    priority_vec_en = prio_upt;

    // Start with old
    priority_vec_w = priority_vec_r;

    // If prio_upt is asserted, update that requestor's priority
    if (prio_upt) begin
      for (int i = 0; i < N; i++) begin
        if (prio_id == i[ID_BITS-1:0]) begin
          priority_vec_w.p[i] = prio;
        end
      end
    end
  end

  //--------------------------------------------------
  // “Sterile” string generation
  //--------------------------------------------------
  always_comb begin
    // Initialize entire bus to zero
    sterile_string = '0;

    // For each priority bit p, set sterile_string[p] if ANY requestor
    // has bit p set AND is requesting
    for (int p = 0; p < PRIORITY_W; p++) begin
      for (int i = 0; i < N; i++) begin
        sterile_string[p] |= (req[i] && priority_vec_r.p[i][p]);
      end
    end
    // Top bit [PRIORITY_W] remains 0
  end

  //--------------------------------------------------
  // Weighted Pointer Update (Combinational)
  //--------------------------------------------------
  always_comb begin
    // Pointer increments on ack
    cycle_label_counter_en = ack;

    // Sum with sterile_inc
    raw_next = cycle_label_counter_r + sterile_inc[PRIORITY_W-1:0];

    // Clamp if result == 0
    cycle_label_counter_w = (raw_next == '0) ? 'b1 : raw_next;
  end

  //--------------------------------------------------
  // Round Request Formation (before rotation/masking)
  //--------------------------------------------------
  always_comb begin
    for (int i = 0; i < N; i++) begin
      // Weighted approach: if req[i] = 1
      // and there's any intersection with pointer bits
      round_req[i] = req[i] && |(priority_vec_r.p[i] & cycle_label_counter_r);
    end
  end

  //--------------------------------------------------
  // Index Pointer Logic
  //--------------------------------------------------
  always_comb begin
    index_ptr_w  = index_ptr_r;
    index_ptr_en = 1'b0;

    // If we have a successful grant (ack && sel_vec_found),
    // rotate the start index for the next cycle
    if (ack && sel_vec_found) begin
      index_ptr_w  = index_ptr_r + 1'b1;
      index_ptr_en = 1'b1;
    end
  end

  //--------------------------------------------------
  // Build "raw_sel_vec", then rotate it
  //--------------------------------------------------
  logic [N-1:0] raw_sel_vec;
  logic [N-1:0] shifted_sel_vec;
  always_comb begin
    // unserved requestors only
    raw_sel_vec = (~sel_vec_mask_r) & round_req;
    // rotate
    shifted_sel_vec = rotate_vec(raw_sel_vec, index_ptr_r);
  end

  //--------------------------------------------------
  // ffs_onehot on shifted_sel_vec
  //--------------------------------------------------
  logic [N-1:0] shifted_sel_vec_1d;
  logic         shifted_sel_vec_found;
  logic [ID_BITS-1:0] shifted_sel_vec_idx;

  ffs_onehot #(.W(N)) u_ffs_shifted_sel (
    .in_bits    (shifted_sel_vec),
    .out_onehot (shifted_sel_vec_1d),
    .found      (shifted_sel_vec_found),
    .idx        (shifted_sel_vec_idx)
  );

  //--------------------------------------------------
  // Translate rotated index back to "real" index
  //--------------------------------------------------
  logic [ID_BITS-1:0] real_sel_idx;
  always_comb begin
    real_sel_idx = (index_ptr_r + shifted_sel_vec_idx) % N;
  end

  //--------------------------------------------------
  // Rebuild the final one-hot in the original indexing
  //--------------------------------------------------
  always_comb begin
    sel_vec_1d   = '0;
    sel_vec_found = shifted_sel_vec_found;
    if (shifted_sel_vec_found) begin
      sel_vec_1d[real_sel_idx] = 1'b1;
    end
  end

  //--------------------------------------------------
  // sel_vec_mask next-state
  //--------------------------------------------------
  always_comb begin
    sel_vec_mask_en = cycle_label_counter_en;

    if (cycle_label_counter_en) begin
      // On pointer increment, clear the mask
      sel_vec_mask_w = '0;
    end
    else begin
      // Otherwise accumulate
      sel_vec_mask_w = sel_vec_mask_r | sel_vec_1d;
    end
  end

  // Debugging only
  always_comb begin
    sel_vec_empty = ~|raw_sel_vec;
  end

  //--------------------------------------------------
  // GNT Outputs
  //--------------------------------------------------
  always_comb begin
    gnt_w  = sel_vec_1d;
    gnt_id = sel_vec_found ? real_sel_idx : '0;
  end

  //--------------------------------------------------
  // Registers (Synchronous Reset)
  //--------------------------------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      priority_vec_r        <= '{default: {PRIORITY_W{1'b1}}};
      cycle_label_counter_r <= 'b1;
      sel_vec_mask_r        <= '0;
      index_ptr_r           <= '0;
    end
    else begin
      // Priority vector
      if (priority_vec_en)
        priority_vec_r <= priority_vec_w;

      // Weighted pointer
      if (cycle_label_counter_en)
        cycle_label_counter_r <= cycle_label_counter_w;

      // Mask
      if (sel_vec_mask_en)
        sel_vec_mask_r <= sel_vec_mask_w;

      // Index pointer
      if (index_ptr_en)
        index_ptr_r <= index_ptr_w;
    end
  end

  //--------------------------------------------------
  // Sterile Logic & FFS Instances
  //--------------------------------------------------
  // 1) 'ffs' for the first '1' in sterile_string -> 3-bit index
  logic dummy_n2;
  ffs #(
    .W($bits(sterile_t))
  ) u_ffs_ss_first_1 (
    .x (sterile_string),
    .y (sterile_string_first_1_idx),
    .n (dummy_n2)
  );

  // 2) Convert that 3-bit index to 5 bits
  always_comb begin
    sterile_string_first_1 = {
      {( (PRIORITY_W+1) - $bits(sterile_string_first_1_idx)){1'b0}},
      sterile_string_first_1_idx
    };
  end

  // 3) 'ffs' with FIND_FIRST_ZERO=1
  logic dummy_n1;
  ffs #(
    .W($bits(sterile_t)),
    .OPT_FIND_FIRST_ZERO(1)
  ) u_ffs_sterile (
    .x (ffs0_post_ss),
    .y (sterile_string_next_0_idx),
    .n (dummy_n1)
  );

  // 4) Convert that 3-bit index to 5 bits
  always_comb begin
    sterile_string_next_0 = {
      {( (PRIORITY_W+1) - $bits(sterile_string_next_0_idx)){1'b0}},
      sterile_string_next_0_idx
    };
  end

  // 5) Use them for your sterile arithmetic
  always_comb begin
    sterile_mask = sterile_string_first_1 - 'b1;
  end

  always_comb begin
    next_0_is_sterile = |((~sterile_string) & sterile_string_next_0);

    sterile_inc_A = {1'b0, sterile_mask[PRIORITY_W-1:0]}
                    ^ (cycle_label_counter_r & sterile_mask[PRIORITY_W-1:0]);
    sterile_inc_B = 'b1;
    sterile_inc_C = next_0_is_sterile ? sterile_string_first_1 : 'b0;
    sterile_inc   = sterile_inc_A + sterile_inc_B + sterile_inc_C;
  end

  always_comb begin
    ffs0_post_ss = {1'b0, cycle_label_counter_r} | sterile_mask;
  end

endmodule

// --------------------------------------------------------------------------
// ffs Module: Finds the first set (or zero) bit from LSB->MSB
// Returns an index of width = $clog2(W)
// --------------------------------------------------------------------------
module ffs #(
  parameter int W = 32,
  parameter bit OPT_FIND_FIRST_ZERO = 0
)(
  input  wire [W-1:0]         x,
  output reg  [$clog2(W)-1:0] y,
  output reg                  n
);

  always_comb begin
    // Default
    y = '0;
    n = 1'b0;

    if (!OPT_FIND_FIRST_ZERO) begin
      // Find first '1'
      for (int i = 0; i < W; i++) begin
        if (x[i]) begin
          y = i[$clog2(W)-1:0];
          n = 1'b1;
          break;
        end
      end
    end
    else begin
      // Find first '0'
      for (int i = 0; i < W; i++) begin
        if (!x[i]) begin
          y = i[$clog2(W)-1:0];
          n = 1'b1;
          break;
        end
      end
    end
  end

endmodule

// --------------------------------------------------------------------------
// ffs_onehot Module: Produces a one-hot from the first set bit in in_bits,
// plus an index, plus a found flag (width = $clog2(W))
// --------------------------------------------------------------------------
module ffs_onehot #(
  parameter int W = 32
)(
  input  wire [W-1:0]         in_bits,
  output reg  [W-1:0]         out_onehot,
  output reg                  found,
  output reg  [$clog2(W)-1:0] idx
);

  always_comb begin
    out_onehot = '0;
    idx        = '0;
    found      = 1'b0;

    for (int i = 0; i < W; i++) begin
      if (!found && in_bits[i]) begin
        out_onehot[i] = 1'b1;
        idx           = i[$clog2(W)-1:0];
        found         = 1'b1;
      end
    end
  end

endmodule
