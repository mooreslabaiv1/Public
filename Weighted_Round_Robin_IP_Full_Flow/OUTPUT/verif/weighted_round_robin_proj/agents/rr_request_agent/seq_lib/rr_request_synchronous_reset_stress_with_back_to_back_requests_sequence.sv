

class rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence extends rr_request_base_seq;
  `uvm_object_utils(rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence)

  // High-level knobs controlling phases
  rand int unsigned pre_active_cycles;     // Step-2: 5-10 cycles pre-reset random activity (rst low/inactive)
  rand int unsigned pseudo_rst_cycles;     // Step-3: emulate 4 cycles of heavy traffic during reset window (driver may idle due to rst)
  rand int unsigned post_reset_throughput_cycles; // Step-5: >=1000 cycles of high-throughput traffic
  rand int unsigned pseudo_reset_repeats;  // Step-6: repeat pseudo reset windows multiple times during traffic

  constraint c_knobs {
    pre_active_cycles inside {[5:10]};
    pseudo_rst_cycles == 4;
    post_reset_throughput_cycles inside {[1000:1500]};
    pseudo_reset_repeats inside {[2:5]};
  }

  function new(string name = "rr_request_synchronous_reset_stress_with_back_to_back_requests_sequence");
    super.new(name);
  endfunction

  // Drive one transaction with explicit values using constrained randomization
  task drive_req_ack(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr",,get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item with explicit values")
    end
    finish_item(tr);
  endtask

  // Randomize and drive one transaction with pattern selection
  task drive_random_pattern();
    rr_request_trans_item tr;
    bit [1:0] kind;
    int unsigned onehot_id;
    bit ack_v;
    logic [31:0] req_v;

    // Select pattern type and onehot id randomly
    void'(std::randomize(kind) with { kind inside {0,1,2,3}; });
    void'(std::randomize(onehot_id) with { onehot_id inside {[0:31]}; });

    // Strongly exercise ack toggling: ~50% chance each cycle
    void'(std::randomize(ack_v) with { ack_v dist {1'b0 := 1, 1'b1 := 1}; });

    case (kind)
      0: req_v = 32'h0000_0000;                    // all-zeros
      1: req_v = 32'hFFFF_FFFF;                    // all-ones
      2: req_v = (32'h1 << onehot_id);             // single-bit set (one-hot)
      default: begin                                // randomized dense mask
        // Create a randomized dense mask by OR of two random one-hots and one random value
        logic [31:0] rnd_any;
        int unsigned id2;
        void'(std::randomize(rnd_any));
        void'(std::randomize(id2) with { id2 inside {[0:31]}; });
        req_v = rnd_any | (32'h1 << onehot_id) | (32'h1 << id2);
      end
    endcase

    drive_req_ack(req_v, ack_v);
  endtask

  // Bursty back-to-back requests for a random burst length
  task drive_burst(int unsigned min_len, int unsigned max_len, int mode = 0);
    int unsigned len, i, id;
    logic [31:0] req_v;
    bit ack_v;
    void'(std::randomize(len) with { len inside {[min_len:max_len]}; });
    for (i = 0; i < len; i++) begin
      case (mode)
        0: begin
          // Alternating one-hot walk with ack toggled each cycle
          void'(std::randomize(id) with { id inside {[0:31]}; });
          req_v = (32'h1 << id);
          ack_v = (i % 2);
          drive_req_ack(req_v, ack_v);
        end
        1: begin
          // Saturated requestors (all ones), ack toggles
          ack_v = (i % 2);
          drive_req_ack(32'hFFFF_FFFF, ack_v);
        end
        2: begin
          // Random pattern each cycle with random ack
          drive_random_pattern();
        end
        default: drive_random_pattern();
      endcase
    end
  endtask

  virtual task body();
    int driven;

    // Randomize high-level knobs
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize sequence-level knobs")
    end

    // Step-2: Pre-active window with randomized, protocol-compliant values
    repeat (pre_active_cycles) begin
      drive_random_pattern();
    end

    // Step-3 and Step-6: Emulate synchronous reset assertion windows multiple times.
    // We cannot drive rst from this agent; still, keep driving items to exercise driver/monitor
    // behavior around reset periods. The driver may pause while rst=1.
    repeat (pseudo_reset_repeats) begin
      // "During reset" 4 cycles (pseudo): drive dense/high activity patterns
      // Mix of all-ones, single-bit, and random patterns
      repeat (pseudo_rst_cycles) begin
        // Force bursts with all requestors active, and ack toggling
        drive_burst(1, 1, 1);
      end

      // Immediately after the pseudo reset window, issue back-to-back randomized requests
      // including all-ones, all-zeros, and one-hot patterns.
      drive_burst(8, 24, 2);
      drive_burst(16, 32, 0);
    end

    // Step-4/5: High-throughput, back-to-back randomized requests for >=1000 cycles.
    // Include bursts where all requestors are active and periods toggling every cycle.
    driven = 0;
    while (driven < post_reset_throughput_cycles) begin
      // Alternate through different stress modes to ensure variety
      drive_burst(8, 32, 1);  // all-ones bursts with ack toggling
      driven += 32;

      drive_burst(16, 48, 0); // one-hot with ack every other cycle
      driven += 48;

      drive_burst(16, 48, 2); // random dense masks with random ack
      driven += 48;

      // Interleave explicit corner cases
      drive_req_ack(32'h0000_0000, 1'b0); // all-zeros
      driven += 1;
      drive_req_ack(32'hFFFF_FFFF, 1'b1); // all-ones with ack high
      driven += 1;

      // Single-bit min/max IDs
      drive_req_ack(32'h0000_0001, 1'b0); // ID 0
      driven += 1;
      drive_req_ack(32'h8000_0000, 1'b1); // ID 31
      driven += 1;
    end
  endtask
endclass