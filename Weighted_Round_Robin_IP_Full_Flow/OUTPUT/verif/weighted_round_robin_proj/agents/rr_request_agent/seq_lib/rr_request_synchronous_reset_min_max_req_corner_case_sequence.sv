
class rr_request_synchronous_reset_min_max_req_corner_case_sequence extends rr_request_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_request_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_request_synchronous_reset_min_max_req_corner_case_sequence)

  // Constrained-random knobs
  rand int unsigned during_reset_alt_cycles;   // cycles worth of items issued "during reset" (driver will hold to reset defaults)
  rand int unsigned state_len_min;             // min cycles per state segment
  rand int unsigned state_len_max;             // max cycles per state segment
  rand int unsigned alternations_post_reset;   // number of 0->1->0->1 alternations after reset deassertion

  constraint c_knobs {
    during_reset_alt_cycles inside {[8:16]};
    state_len_min inside {[1:2]};
    state_len_max inside {[2:6]};
    state_len_max >= state_len_min;
    alternations_post_reset inside {[40:80]};  // ensure at least ~80 segments -> >= 80 cycles in worst case
  }

  function new(string name = "rr_request_synchronous_reset_min_max_req_corner_case_sequence");
    super.new(name);
  endfunction

  // Drive exactly one cycle via CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Drive a segment of len cycles with fixed req value, ack held low
  task drive_segment(logic [31:0] req_v, int unsigned len);
    int unsigned i;
    for (i = 0; i < len; i++) begin
      drive_cycle(req_v, 1'b0);
    end
  endtask

  virtual task body();
    int unsigned alt;
    int unsigned len0, len1;

    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request min/max reset corner knobs")
    end

    // Issue items intended for "during reset" window: alternate all-zeros and all-ones
    // Note: driver holds interface to reset defaults while rst=1, satisfying req_min_during_reset and stability expectation.
    repeat (during_reset_alt_cycles) begin
      // Alternate per-cycle during this phase to seed queue early; driver will output after rst deassert
      drive_cycle(32'h0000_0000, 1'b0);
      drive_cycle(32'hFFFF_FFFF, 1'b0);
    end

    // Post-reset: alternate blocks of all 0s then all 1s, lengths randomized within bounds
    // Start with all 0s immediately after reset to meet req_min_post_reset coverage
    for (alt = 0; alt < alternations_post_reset; alt++) begin
      void'(std::randomize(len0) with { len0 inside {[state_len_min:state_len_max]}; });
      void'(std::randomize(len1) with { len1 inside {[state_len_min:state_len_max]}; });

      // Segment A: all zeros
      drive_segment(32'h0000_0000, len0);

      // Segment B: all ones (exercise full contention)
      drive_segment(32'hFFFF_FFFF, len1);
    end

    // Tail: a couple of cycles to settle at zeros
    drive_segment(32'h0000_0000, $urandom_range(2,4));
  endtask
endclass