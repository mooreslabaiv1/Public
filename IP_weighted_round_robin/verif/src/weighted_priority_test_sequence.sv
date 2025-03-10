class weighted_priority_test_sequence extends uvm_sequence;
  `uvm_object_utils(weighted_priority_test_sequence)

  // If you need to explicitly access the sequencers:
  // `uvm_declare_p_sequencer(weighted_priority_test_virtual_sequencer)

  function new(string name = "weighted_priority_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    // 1) Set different weights
    weighted_round_robin_priority_update_agent_base_transaction prio_tr;
    int N = 32;

    for (int i = 0; i < N; i++) begin
      prio_tr = weighted_round_robin_priority_update_agent_base_transaction::type_id::create($sformatf("prio_tr_%0d", i));
      prio_tr.prio_id  = i;

      // Example weighting
      if (i == 0)      prio_tr.prio = 4'hF; // highest
      else if (i == 1) prio_tr.prio = 4'hA; // mid-high
      else if (i == 2) prio_tr.prio = 4'h5; // mid
      else             prio_tr.prio = 4'h1; // low

      prio_tr.prio_upt = 1'b1;
      start_item(prio_tr);
      finish_item(prio_tr);
    end

    // 2) Drive requests from all requestors for multiple cycles
    weighted_round_robin_requestor_agent_base_transaction req_tr;
    int num_cycles = 20;

    for (int cycle = 0; cycle < num_cycles; cycle++) begin
      req_tr = weighted_round_robin_requestor_agent_base_transaction::type_id::create($sformatf("req_tr_%0d", cycle));
      req_tr.req = 32'hFFFF_FFFF; // all requestors
      // ack is typically driven by the driver automatically
      // but we can keep ack=0 in the sequence or let the driver handle it
      start_item(req_tr);
      finish_item(req_tr);
      // optional wait
      @(posedge this.m_sequencer.phase_ready_to_end); 
    end
  endtask
endclass
