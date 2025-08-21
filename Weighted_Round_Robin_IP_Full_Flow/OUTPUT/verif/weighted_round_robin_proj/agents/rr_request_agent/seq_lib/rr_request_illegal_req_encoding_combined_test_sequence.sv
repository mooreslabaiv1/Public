

class rr_request_illegal_req_encoding_combined_test_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_illegal_req_encoding_combined_test_sequence)

  // Knobs
  rand int unsigned all_zero_cycles;
  rand int unsigned all_one_cycles;
  rand int unsigned multi_illegal_cycles;
  rand int unsigned idle_tail_cycles;

  constraint c_knobs {
    all_zero_cycles inside {[4:12]};
    all_one_cycles inside {[4:12]};
    multi_illegal_cycles inside {[24:48]};
    idle_tail_cycles inside {[4:12]};
  }

  function new(string name = "rr_request_illegal_req_encoding_combined_test_sequence");
    super.new(name);
  endfunction

  // Drive one transaction cycle with explicit values
  task drive_explicit(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_illegal_req",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Randomization failed in drive_explicit")
    end
    finish_item(tr);
  endtask

  // Helper: explicit directed multi-bit patterns
  task drive_directed_multibit_patterns();
    rr_request_trans_item tr;
    logic [31:0] patterns[$];
    int i;

    patterns.push_back(32'h0000_000C); // 1100
    patterns.push_back(32'h0000_000A); // 1010
    patterns.push_back(32'h0000_0003); // 0011
    patterns.push_back(32'h0000_000F); // 1111
    patterns.push_back(32'h8000_0001); // MSB + LSB set

    foreach (patterns[i]) begin
      tr = rr_request_trans_item::type_id::create($sformatf("tr_dir_%0d", i),,get_full_name());
      start_item(tr);
      if (!tr.randomize() with { req == patterns[i]; ack == 1'b0; }) begin
        `uvm_error(get_full_name(), "Randomization failed for directed multi-bit pattern")
      end
      finish_item(tr);
    end
  endtask

  // Helper: randomized multi-bit-set illegal encodings (countones > 1)
  task drive_random_multibit_illegals(int unsigned n);
    int unsigned i;
    logic [31:0] req_v;
    bit ack_v;
    rr_request_trans_item tr;
    i = 0;
    ack_v = 1'b0;
    for (i = 0; i < n; i++) begin
      // Generate a value with at least two bits set
      req_v = '0;
      // Simple method: OR several random one-hot positions plus a random mask
      begin
        int unsigned id0, id1;
        logic [31:0] rnd_any;
        void'(std::randomize(id0) with { id0 inside {[0:31]}; });
        void'(std::randomize(id1) with { id1 inside {[0:31]}; });
        void'(std::randomize(rnd_any));
        req_v = (32'h1 << id0) | (32'h1 << id1) | rnd_any;
      end
      // Ensure it's not all-zero and has at least two bits set
      if ($countones(req_v) < 2) begin
        // Force at least two bits
        req_v = 32'h3;
      end

      tr = rr_request_trans_item::type_id::create($sformatf("tr_illegal_rand_%0d", i),,get_full_name());
      start_item(tr);
      if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
        `uvm_error(get_full_name(), "Randomization failed for randomized multi-bit illegal")
      end
      finish_item(tr);
    end
  endtask

  virtual task body();
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize sequence knobs")
    end

    // Phase-1: All zeros (no requestors active) for several cycles
    repeat (all_zero_cycles) begin
      drive_explicit(32'h0000_0000, 1'b0);
    end

    // Phase-2: All ones (maximum value) for several cycles
    repeat (all_one_cycles) begin
      drive_explicit(32'hFFFF_FFFF, 1'b0);
    end

    // Phase-3: Multiple bits set (illegal if one-hot was required)
    drive_directed_multibit_patterns();
    drive_random_multibit_illegals(multi_illegal_cycles);

    // Tail idle
    repeat (idle_tail_cycles) begin
      drive_explicit(32'h0000_0000, 1'b0);
    end
  endtask
endclass