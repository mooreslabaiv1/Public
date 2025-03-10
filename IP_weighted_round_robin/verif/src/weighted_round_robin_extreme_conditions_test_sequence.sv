`ifndef WEIGHTED_ROUND_ROBIN_EXTREME_CONDITIONS_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_EXTREME_CONDITIONS_TEST_SEQUENCE__SV

// 1) Virtual Sequencer
class extreme_conditions_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(extreme_conditions_virtual_sequencer)

  // Agents
  weighted_round_robin_requestor_agent_base_seqr       requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "extreme_conditions_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass


// 2) Priority Subsequence (Optional minimal priority setup)
class extreme_conditions_test_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(extreme_conditions_test_prio_subseq)

  function new(string name = "extreme_conditions_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    // If you want to set all weights = 1 (for instance)
    // This step can be omitted if your design doesn't need explicit priority setup.
    weighted_round_robin_priority_update_agent_base_transaction prio_item;
    int N = 32;

    for (int i = 0; i < N; i++) begin
      prio_item = weighted_round_robin_priority_update_agent_base_transaction
                  ::type_id::create($sformatf("extreme_prio_%0d", i));
      prio_item.prio_id  = i[4:0];
      prio_item.prio     = 4'd1;  // e.g., priority=1
      prio_item.prio_upt = 1'b1;

      start_item(prio_item);
      finish_item(prio_item);
    end
  endtask
endclass


// 3) Requestor Subsequence: "Extreme" conditions
//    - Step A: req=0x0  => no requests => expect gnt_w=0, gnt_id=0
//    - Step B: req=0xFFFF_FFFF => all requestors => round-robin
class extreme_conditions_test_req_subseq extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(extreme_conditions_test_req_subseq)

  function new(string name = "extreme_conditions_test_req_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_tr;

    // Step A: No requests
    req_tr = weighted_round_robin_requestor_agent_base_transaction
             ::type_id::create("no_requests");
    req_tr.req = 32'h0000_0000; // no requestor active

    start_item(req_tr);
    finish_item(req_tr);

    // [Optional] Wait some cycles or checks
    repeat (5) @(posedge p_sequencer.drv_if.clk);

    // Step B: All requests
    req_tr = weighted_round_robin_requestor_agent_base_transaction
             ::type_id::create("all_requests");
    req_tr.req = 32'hFFFF_FFFF; // all requestors active
    start_item(req_tr);
    finish_item(req_tr);

    // [Optional] Wait or do more checks
    repeat (10) @(posedge p_sequencer.drv_if.clk);

  endtask
endclass


// 4) Virtual Sequence: forks priority + request subsequences in parallel
class extreme_conditions_test_sequence extends uvm_sequence;
  `uvm_object_utils(extreme_conditions_test_sequence)
  `uvm_declare_p_sequencer(extreme_conditions_virtual_sequencer)

  function new(string name = "extreme_conditions_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    extreme_conditions_test_prio_subseq prio_seq;
    extreme_conditions_test_req_subseq  req_seq;

    // Create sub-sequences
    prio_seq = extreme_conditions_test_prio_subseq::type_id::create("prio_seq");
    req_seq  = extreme_conditions_test_req_subseq::type_id::create("req_seq");

    fork
      // If needed, set minimal priority
      prio_seq.start(p_sequencer.priority_update_seqr);

      // Drive the extreme request conditions
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_EXTREME_CONDITIONS_TEST_SEQUENCE__SV
