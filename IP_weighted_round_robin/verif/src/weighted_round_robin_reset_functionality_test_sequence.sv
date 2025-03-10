`ifndef WEIGHTED_ROUND_ROBIN_RESET_FUNCTIONALITY_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_RESET_FUNCTIONALITY_TEST_SEQUENCE__SV

class reset_func_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(reset_func_virtual_sequencer)

  weighted_round_robin_requestor_agent_base_seqr       requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "reset_func_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

class reset_func_test_prio_subseq extends uvm_sequence;
  `uvm_object_utils(reset_func_test_prio_subseq)

  function new(string name="reset_func_test_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_item;
    // For some cycles, set random or varied priorities
    for (int cycle = 0; cycle < 5; cycle++) begin
      prio_item = weighted_round_robin_priority_update_agent_base_transaction::type_id::create($sformatf("prio_item_pre_rst_%0d", cycle));
      assert(prio_item.randomize());
      start_item(prio_item);
      finish_item(prio_item);
    end

    // Now the test might toggle reset externally. We keep waiting...
    `uvm_info(get_type_name(),"Waiting for reset toggles...",UVM_LOW);
    // You can wait #100 or rely on some environment event. For now, just an example:
    #(100);

    // After reset is released, do more cycles
    for (int cycle = 0; cycle < 5; cycle++) begin
      prio_item = weighted_round_robin_priority_update_agent_base_transaction::type_id::create($sformatf("prio_item_post_rst_%0d", cycle));
      assert(prio_item.randomize());
      start_item(prio_item);
      finish_item(prio_item);
    end
  endtask
endclass

class reset_func_test_requestor_subseq extends uvm_sequence;
  `uvm_object_utils(reset_func_test_requestor_subseq)

  function new(string name="reset_func_test_requestor_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_item;
    int num_cycles_before_reset = 5;
    int num_cycles_after_reset  = 5;

    // 1) Drive requests for pre-reset cycles
    for (int cycle = 0; cycle < num_cycles_before_reset; cycle++) begin
      req_item = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_item_pre_rst_%0d", cycle));
      req_item.randomize();
      start_item(req_item);
      finish_item(req_item);
    end

    // Wait for reset toggling from the test
    #(100);

    // 2) After reset is released, drive more requests
    for (int cycle = 0; cycle < num_cycles_after_reset; cycle++) begin
      req_item = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_item_post_rst_%0d", cycle));
      req_item.randomize();
      start_item(req_item);
      finish_item(req_item);
    end
  endtask
endclass

class reset_func_test_vseq extends uvm_sequence;
  `uvm_object_utils(reset_func_test_vseq)
  `uvm_declare_p_sequencer(reset_func_virtual_sequencer)

  function new(string name="reset_func_test_vseq");
    super.new(name);
  endfunction

  virtual task body();
    reset_func_test_prio_subseq     prio_seq;
    reset_func_test_requestor_subseq req_seq;

    prio_seq = reset_func_test_prio_subseq::type_id::create("prio_seq");
    req_seq  = reset_func_test_requestor_subseq::type_id::create("req_seq");

    fork
      prio_seq.start(p_sequencer.priority_update_seqr);
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_RESET_FUNCTIONALITY_TEST_SEQUENCE__SV
