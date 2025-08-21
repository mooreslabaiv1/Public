
class rr_request_grant_output_boundary_requestor_id_and_one_hot_test_sequence extends rr_request_base_seq;
  // You got to: 
  // Code test_sequence logic
  // Stricly use SystemVerilog Constrained-random stimulus for stimulus generation.
  // ONLY use the rr_request_trans_item class for transactions (do NOT use other agents' transaction items). 

  `uvm_object_utils(rr_request_grant_output_boundary_requestor_id_and_one_hot_test_sequence)

  // Constrained-random knobs to control directed phases
  rand int unsigned pre_idle_cycles;     // initial idle cycles after reset
  rand int unsigned observe_cycles;      // number of cycles to hold single requester active
  rand int unsigned idle_between;        // idle cycles between min and max stimuli
  rand int unsigned repeats;             // how many times to repeat the min/max pair

  constraint c_knobs {
    pre_idle_cycles  == 5;               // exactly 5 cycles to establish idle state
    observe_cycles   inside {[2:4]};     // at least 2 cycles observation
    idle_between     == 5;               // exactly 5 cycles idle between stimuli
    repeats          inside {[2:3]};     // repeat at least twice
  }

  function new(string name = "rr_request_grant_output_boundary_requestor_id_and_one_hot_test_sequence");
    super.new(name);
  endfunction

  // Drive one cycle with explicit values via CRV
  task drive_cycle(logic [31:0] req_v, bit ack_v);
    rr_request_trans_item tr;
    tr = rr_request_trans_item::type_id::create("tr_req_ack", , get_full_name());
    start_item(tr);
    if (!tr.randomize() with { req == req_v; ack == ack_v; }) begin
      `uvm_error(get_full_name(), "Failed to randomize rr_request_trans_item")
    end
    finish_item(tr);
  endtask

  // Idle N cycles (req=0, ack=0)
  task idle_n(int unsigned n);
    int unsigned i;
    for (i = 0; i < n; i++) begin
      drive_cycle(32'h0000_0000, 1'b0);
    end
  endtask

  // Hold a single requester active for observe_cycles with ack low
  task hold_onehot(bit min_not_max);
    int unsigned i;
    logic [31:0] mask;
    mask = min_not_max ? 32'h0000_0001 : 32'h8000_0000; // bit 0 or bit 31
    for (i = 0; i < observe_cycles; i++) begin
      // "Keep ack low for this cycle." We maintain ack low throughout observation.
      drive_cycle(mask, 1'b0);
    end
  endtask

  virtual task body();
    if (!randomize()) begin
      `uvm_error(get_full_name(), "Failed to randomize boundary one-hot test knobs")
    end

    // Step-3: After reset, idle for 5 cycles
    idle_n(pre_idle_cycles);

    // Steps 4-6: Repeat directed min/max stimuli
    repeat (repeats) begin
      // Step-4: Only minimum requester active (ID=0), ack low; observe for >=2 cycles
      hold_onehot(1'b1);
      // Deassert and idle 5 cycles
      idle_n(idle_between);

      // Step-5: Only maximum requester active (ID=31), ack low; observe for >=2 cycles
      hold_onehot(1'b0);
      // Deassert and idle 5 cycles
      idle_n(idle_between);
    end

    // Tail idle to let outputs settle
    idle_n($urandom_range(3,6));
  endtask
endclass