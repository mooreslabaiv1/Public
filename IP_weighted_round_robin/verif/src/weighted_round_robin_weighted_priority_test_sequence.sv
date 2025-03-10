`ifndef WEIGHTED_ROUND_ROBIN_WEIGHTED_PRIORITY_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_WEIGHTED_PRIORITY_TEST_SEQUENCE__SV

class weighted_priority_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(weighted_priority_virtual_sequencer)

  // Sub-sequencer handles
  weighted_round_robin_requestor_agent_base_seqr        requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr  priority_update_seqr;

  function new(string name = "weighted_priority_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

class weighted_priority_test_requestor_subseq extends uvm_sequence;
  `uvm_object_utils(weighted_priority_test_requestor_subseq)

  function new(string name = "weighted_priority_test_requestor_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_tr;

    // For a certain number of cycles, drive all request bits
    int num_cycles = 20;
    for (int cycle = 0; cycle < num_cycles; cycle++) begin
      req_tr = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_tr_%0d", cycle));
      req_tr.req = 32'hFFFF_FFFF; // all requestors requesting
      // ack is typically set in the driver automatically upon seeing a grant
      start_item(req_tr);
      finish_item(req_tr);

      // optional delay or wait
      // @(posedge get_sequencer().m_sequencer.run_phase_done); 
      // @(posedge p_sequencer.requestor_seqr.drv_if.clk);
      #10;
    end
  endtask
endclass

class weighted_priority_test_prio_subseq extends uvm_sequence;
  `uvm_object_utils(weighted_priority_test_prio_subseq)

  function new(string name = "weighted_priority_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_tr;

    // Assign different weights
    int N = 32;
    for (int i = 0; i < N; i++) begin
      prio_tr = weighted_round_robin_priority_update_agent_base_transaction::type_id::create($sformatf("prio_tr_%0d", i));
      prio_tr.prio_id  = i;

      // Example weighting
      if (i == 0)      prio_tr.prio = 'hF; // highest
      else if (i == 1) prio_tr.prio = 'hA; // mid-high
      else if (i == 2) prio_tr.prio = 'h5; // mid
      else             prio_tr.prio = 'h1; // low

      prio_tr.prio_upt = 1'b1;

      start_item(prio_tr);
      finish_item(prio_tr);
    end
  endtask
endclass

class weighted_priority_test_vseq extends uvm_sequence;
  `uvm_object_utils(weighted_priority_test_vseq)
  `uvm_declare_p_sequencer(weighted_priority_virtual_sequencer)

  function new(string name = "weighted_priority_test_vseq");
    super.new(name);
  endfunction

  virtual task body();
    // Create sub-sequences
    weighted_priority_test_requestor_subseq req_seq;
    weighted_priority_test_prio_subseq prio_seq;

    req_seq  = weighted_priority_test_requestor_subseq::type_id::create("req_seq");
    prio_seq = weighted_priority_test_prio_subseq::type_id::create("prio_seq");

    fork
      // Start requestor sub-sequence on requestor_seqr
      req_seq.start(p_sequencer.requestor_seqr);

      // Start prio sub-sequence on priority_update_seqr
      prio_seq.start(p_sequencer.priority_update_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_WEIGHTED_PRIORITY_TEST_SEQUENCE__SV
