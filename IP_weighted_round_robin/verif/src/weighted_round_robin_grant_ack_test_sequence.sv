`ifndef WEIGHTED_ROUND_ROBIN_GRANT_ACK_TEST_SEQUENCES__SV
`define WEIGHTED_ROUND_ROBIN_GRANT_ACK_TEST_SEQUENCES__SV

// 1) Virtual Sequencer
class grant_ack_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(grant_ack_virtual_sequencer)

  // Agents
  weighted_round_robin_requestor_agent_base_seqr        requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr  priority_update_seqr;

  function new(string name = "grant_ack_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

// 2) Priority Setup Subsequence
class grant_ack_test_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(grant_ack_test_prio_subseq)

  function new(string name = "grant_ack_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_txn;
    int N = 32;

    // For example, set each requestor to priority=4
    for (int i=0; i<N; i++) begin
      prio_txn = weighted_round_robin_priority_update_agent_base_transaction
                 ::type_id::create($sformatf("grant_ack_prio_%0d", i));

      prio_txn.prio_id  = i;
      prio_txn.prio     = 4'h4;  // all = 4
      prio_txn.prio_upt = 1'b1;

      start_item(prio_txn);
      finish_item(prio_txn);
    end
  endtask
endclass

// 3) Requestor Subsequence
class grant_ack_test_requestor_subseq extends weighted_round_robin_requestor_base_sequence; //uvm_sequence;
  `uvm_object_utils(grant_ack_test_requestor_subseq)

  function new(string name = "grant_ack_test_requestor_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_txn;
    int cycles = 10;

    for (int c = 0; c < cycles; c++) begin
      // 1) Transaction that might use ack=0
      req_txn = weighted_round_robin_requestor_agent_base_transaction
                ::type_id::create($sformatf("req_noack_c%0d", c));
      // Example: only requestors [3..0]
      req_txn.req = 32'h0000_000F;
      // If transaction-level ack: req_txn.ack = 1'b0;
      start_item(req_txn);
      finish_item(req_txn);

      // Wait a clock/phase
      @(posedge p_sequencer.drv_if.clk);

      // 2) Another transaction with ack=1
      req_txn = weighted_round_robin_requestor_agent_base_transaction
                ::type_id::create($sformatf("req_ack_c%0d", c));
      req_txn.req = 32'h0000_000F;
      // If transaction-level ack: req_txn.ack = 1'b1;
      start_item(req_txn);
      finish_item(req_txn);

      // Wait a clock/phase
      @(posedge p_sequencer.drv_if.clk);
    end
  endtask
endclass

// 4) Virtual Sequence
class grant_ack_test_vseq extends uvm_sequence;
  `uvm_object_utils(grant_ack_test_vseq)
  `uvm_declare_p_sequencer(grant_ack_virtual_sequencer)

  function new(string name = "grant_ack_test_vseq");
    super.new(name);
  endfunction

  virtual task body();
    grant_ack_test_prio_subseq       prio_seq;
    grant_ack_test_requestor_subseq  req_seq;

    prio_seq = grant_ack_test_prio_subseq::type_id::create("prio_seq");
    req_seq  = grant_ack_test_requestor_subseq::type_id::create("req_seq");

    fork
      // Drive priority updates
      prio_seq.start(p_sequencer.priority_update_seqr);

      // Drive request transactions
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_GRANT_ACK_TEST_SEQUENCES__SV
