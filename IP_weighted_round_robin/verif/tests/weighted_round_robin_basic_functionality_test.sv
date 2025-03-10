`ifndef BASIC_FUNCTIONALITY_TEST__SV
`define BASIC_FUNCTIONALITY_TEST__SV

`include "uvm_macros.svh"
`include "weighted_round_robin_basic_functionality_test_sequence.sv"

class weighted_round_robin_basic_functionality_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_basic_functionality_test)

  weighted_round_robin_env env;
  basic_functionality_virtual_sequencer virtual_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = weighted_round_robin_env::type_id::create("env", this);
    virtual_seqr = basic_functionality_virtual_sequencer::type_id::create("virtual_seqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Set sequencer handles directly in connect_phase
    virtual_seqr.requestor_seqr = env.requestor_agent.requestor_seqr;
    virtual_seqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;

  endfunction

  virtual task run_phase(uvm_phase phase);
    basic_functionality_virtual_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = basic_functionality_virtual_sequence::type_id::create("seq");
    seq.start(virtual_seqr);

    phase.drop_objection(this);
  endtask

endclass: weighted_round_robin_basic_functionality_test

`endif // BASIC_FUNCTIONALITY_TEST__SV