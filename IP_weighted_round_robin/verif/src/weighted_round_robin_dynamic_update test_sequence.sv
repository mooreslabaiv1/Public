`ifndef WEIGHTED_ROUND_ROBIN_DYNAMIC_UPDATE_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_DYNAMIC_UPDATE_TEST_SEQUENCE__SV

class dynamic_update_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(dynamic_update_virtual_sequencer)

  weighted_round_robin_requestor_agent_base_seqr        requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr  priority_update_seqr;

  function new(string name="dynamic_update_virtual_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass

class dynamic_update_test_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(dynamic_update_test_prio_subseq)

  function new(string name="dynamic_update_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_tr;
    int N = 32;

    // 1) Set all requestors to same weight
    for (int i = 0; i < N; i++) begin
      prio_tr = weighted_round_robin_priority_update_agent_base_transaction::type_id::create($sformatf("prio_init_%0d", i));
      prio_tr.prio_id  = i;
      prio_tr.prio     = 4'h4; // uniform
      prio_tr.prio_upt = 1'b1;
      start_item(prio_tr);
      finish_item(prio_tr);
    end

    repeat (5) @(posedge p_sequencer.drv_if.clk);

    // 2) Update priority of requestor ID=3 (example)
    prio_tr = weighted_round_robin_priority_update_agent_base_transaction::type_id::create("prio_upd_id3");
    prio_tr.prio_id  = 3;
    prio_tr.prio     = 4'hF; // highest
    prio_tr.prio_upt = 1'b1;
    start_item(prio_tr);
    finish_item(prio_tr);
  endtask
endclass

class dynamic_update_test_requestor_subseq extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(dynamic_update_test_requestor_subseq)

  function new(string name="dynamic_update_test_requestor_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_tr;
    // Drive requests continuously for e.g. 20 cycles
    // in two phases: pre-update (10 cycles), post-update (10 cycles)

    // Pre-update
    for (int c = 0; c < 10; c++) begin
      req_tr = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_preupd_%0d", c));
      req_tr.req = 32'hFFFF_FFFF; // all requesting
      start_item(req_tr);
      finish_item(req_tr);
    end

    // Wait for the priority sub-sequence to do the mid-run update
    repeat (5) @(posedge p_sequencer.drv_if.clk);

    // Post-update
    for (int c = 0; c < 10; c++) begin
      req_tr = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_postupd_%0d", c));
      req_tr.req = 32'hFFFF_FFFF;
      start_item(req_tr);
      finish_item(req_tr);
    end
  endtask
endclass

class dynamic_update_test_vseq extends uvm_sequence;
  `uvm_object_utils(dynamic_update_test_vseq)
  `uvm_declare_p_sequencer(dynamic_update_virtual_sequencer)

  function new(string name="dynamic_update_test_vseq");
    super.new(name);
  endfunction

  virtual task body();
    // Sub-sequences
    dynamic_update_test_prio_subseq      prio_seq;
    dynamic_update_test_requestor_subseq req_seq;

    prio_seq = dynamic_update_test_prio_subseq::type_id::create("prio_seq");
    req_seq  = dynamic_update_test_requestor_subseq::type_id::create("req_seq");

    fork
      prio_seq.start(p_sequencer.priority_update_seqr);
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_DYNAMIC_UPDATE_TEST_SEQUENCE__SV