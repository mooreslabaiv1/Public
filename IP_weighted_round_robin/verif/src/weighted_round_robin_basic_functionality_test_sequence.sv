`ifndef WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST_SEQUENCE__SV

// Sequence for requestor agent
class requestor_sequence_basic_functionality extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(requestor_sequence_basic_functionality)

  function new(string name = "requestor_sequence_basic_functionality");
    super.new(name);
  endfunction:new

  virtual task body();
    weighted_round_robin_requestor_agent_base_transaction req_trans;
    req_trans = weighted_round_robin_requestor_agent_base_transaction::type_id::create("req_trans");
    req_trans.req = '1; // All requestors are requesting.
    forever begin
      start_item(req_trans);
      finish_item(req_trans);
      @(posedge p_sequencer.drv_if.clk); // Wait for a clock cycle
    end
  endtask: body

endclass

// Sequence for priority update agent
class priority_update_sequence_basic_functionality extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(priority_update_sequence_basic_functionality)

  function new(string name = "priority_update_sequence_basic_functionality");
    super.new(name);
  endfunction:new

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_trans;
    int i;
    prio_trans = weighted_round_robin_priority_update_agent_base_transaction::type_id::create("prio_trans");

    // Need to send this transaction once for each requestor.
    for (i = 0; i < 32; i++) begin
      if (!prio_trans.randomize() with {
        prio_upt == 1; // ensure we always update
        prio inside {[1:10]};
        }) begin
          `uvm_error("RAND_FAIL","Failed to randomize prio transaction")
        end
        start_item(prio_trans);
        finish_item(prio_trans);
        @(posedge p_sequencer.drv_if.clk);
    end
  endtask: body

endclass

// Virtual sequencer
class basic_functionality_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(basic_functionality_virtual_sequencer)

  // Declare handles to the sequencers of both agents
  weighted_round_robin_requestor_agent_base_seqr requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "basic_functionality_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Removed connect_phase and get calls

endclass

// Virtual sequence
class basic_functionality_virtual_sequence extends uvm_sequence;
  `uvm_object_utils(basic_functionality_virtual_sequence)
  `uvm_declare_p_sequencer(basic_functionality_virtual_sequencer)

  function new(string name = "basic_functionality_virtual_sequence");
    super.new(name);
  endfunction:new

  virtual task body();
    // Start both sequences
    requestor_sequence_basic_functionality req_seq;
    priority_update_sequence_basic_functionality prio_seq;
    req_seq = requestor_sequence_basic_functionality::type_id::create("req_seq");
    prio_seq = priority_update_sequence_basic_functionality::type_id::create("prio_seq");
    fork
      // Kick off the priority update sequence
      prio_seq.start(p_sequencer.priority_update_seqr);
      // Kick off the requestor sequence
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask: body

endclass

`endif // WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST_SEQUENCE__SV