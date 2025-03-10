`ifndef WEIGHTED_ROUND_ROBIN_STARVATION_RISK_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_STARVATION_RISK_TEST_SEQUENCE__SV

// 1) Virtual Sequencer referencing two agents
class starvation_risk_test_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(starvation_risk_test_virtual_sequencer)

  weighted_round_robin_requestor_agent_base_seqr       requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "starvation_risk_test_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass


// 2) Priority Subsequence for Starvation Risk
//    Step 1: Favored => weight=10, others => weight=1
class starvation_risk_test_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(starvation_risk_test_prio_subseq)

  function new(string name = "starvation_risk_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_item;
    int num_requestors    = 32;
    int favored_requestor = 0;  // e.g. requestor #0 is favored

    // 1) Favored requestor => weight=10
    prio_item = weighted_round_robin_priority_update_agent_base_transaction
                ::type_id::create("favored_prio");
    prio_item.prio_id  = favored_requestor[4:0];
    prio_item.prio     = 4'd10; // or 'hA
    prio_item.prio_upt = 1'b1;
    start_item(prio_item);
    finish_item(prio_item);

    // 2) Set the others => weight=1
    for (int i = 0; i < num_requestors; i++) begin
      if (i == favored_requestor) continue;

      prio_item = weighted_round_robin_priority_update_agent_base_transaction
                  ::type_id::create($sformatf("other_prio_%0d", i));
      prio_item.prio_id  = i[4:0];
      prio_item.prio     = 4'd1;
      prio_item.prio_upt = 1'b1;

      start_item(prio_item);
      finish_item(prio_item);
    end
  endtask
endclass


// 3) Requestor Subsequence
//    Step 2: Continuously drive requests for an extended period
class starvation_risk_test_req_subseq extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(starvation_risk_test_req_subseq)

  function new(string name = "starvation_risk_test_req_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_tr;
    int max_cycles = 1000;  // extended run

    for (int c = 0; c < max_cycles; c++) begin
      req_tr = weighted_round_robin_requestor_agent_base_transaction
               ::type_id::create($sformatf("req_cycle_%0d", c));

      // All requestors active
      req_tr.req = 32'hFFFF_FFFF;
      // ack is toggled automatically by the driver upon seeing gnt_w

      start_item(req_tr);
      finish_item(req_tr);

      // small delay
      repeat (10) @(posedge p_sequencer.drv_if.clk);
    end
  endtask
endclass


// 4) Virtual Sequence that forks the priority and request subsequences
class starvation_risk_test_sequence extends uvm_sequence;
  `uvm_object_utils(starvation_risk_test_sequence)
  `uvm_declare_p_sequencer(starvation_risk_test_virtual_sequencer)

  function new(string name = "starvation_risk_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    starvation_risk_test_prio_subseq prio_seq;
    starvation_risk_test_req_subseq  req_seq;

    // Create sub-sequences
    prio_seq = starvation_risk_test_prio_subseq::type_id::create("prio_seq");
    req_seq  = starvation_risk_test_req_subseq::type_id::create("req_seq");

    fork
      // Sub-sequence for priority updates (favored=10, others=1)
      prio_seq.start(p_sequencer.priority_update_seqr);

      // Sub-sequence for continuous requests
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_STARVATION_RISK_TEST_SEQUENCE__SV