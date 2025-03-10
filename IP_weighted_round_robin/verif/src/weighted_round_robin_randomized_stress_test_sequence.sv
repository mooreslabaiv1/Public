`ifndef WEIGHTED_ROUND_ROBIN_RANDOMIZED_STRESS_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_RANDOMIZED_STRESS_TEST_SEQUENCE__SV

// Virtual Sequencer
class randomized_stress_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(randomized_stress_virtual_sequencer)

  weighted_round_robin_requestor_agent_base_seqr       requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "randomized_stress_virtual_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass

// Priority Sub-sequence: random prio, prio_id, prio_upt
class randomized_stress_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(randomized_stress_prio_subseq)

  function new(string name = "randomized_stress_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_txn;
    int cycles = 50; // how many random updates

    for (int i = 0; i < cycles; i++) begin
      prio_txn = weighted_round_robin_priority_update_agent_base_transaction
                 ::type_id::create($sformatf("prio_txn_%0d", i));

      // Let constraint solver pick prio, prio_id, prio_upt
      if (!prio_txn.randomize()) begin
        `uvm_error("RAND_FAIL","Failed to randomize priority transaction")
      end

      start_item(prio_txn);
      finish_item(prio_txn);

      // small random delay
      // or simply do a few clock cycles:
      repeat ($urandom_range(0,3)) @(posedge p_sequencer.drv_if.clk);
    end
  endtask
endclass

// Requestor Sub-sequence: random requests
class randomized_stress_req_subseq extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(randomized_stress_req_subseq)

  function new(string name = "randomized_stress_req_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_txn;
    int cycles = 100;

    for (int i = 0; i < cycles; i++) begin
      req_txn = weighted_round_robin_requestor_agent_base_transaction
                ::type_id::create($sformatf("req_txn_%0d", i));

      // Randomize 'req' fully (see the transaction's constraints)
      if (!req_txn.randomize()) begin
        `uvm_error("RAND_FAIL","Failed to randomize request transaction")
      end

      start_item(req_txn);
      finish_item(req_txn);

      // small random delay
      // or simply do a few clock cycles:
      repeat ($urandom_range(0,3)) @(posedge p_sequencer.drv_if.clk);
    end
  endtask
endclass

// Top-level Virtual Sequence
class weighted_round_robin_randomized_stress_test_sequence extends uvm_sequence;
  `uvm_object_utils(weighted_round_robin_randomized_stress_test_sequence)
  `uvm_declare_p_sequencer(randomized_stress_virtual_sequencer)

  function new(string name = "weighted_round_robin_randomized_stress_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    randomized_stress_prio_subseq prio_seq;
    randomized_stress_req_subseq  req_seq;

    prio_seq = randomized_stress_prio_subseq::type_id::create("prio_seq");
    req_seq  = randomized_stress_req_subseq::type_id::create("req_seq");

    fork
      prio_seq.start(p_sequencer.priority_update_seqr);
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_RANDOMIZED_STRESS_TEST_SEQUENCE__SV
