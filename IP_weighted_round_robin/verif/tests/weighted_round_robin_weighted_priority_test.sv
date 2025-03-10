`ifndef WEIGHTED_PRIORITY_TEST__SV
`define WEIGHTED_PRIORITY_TEST__SV

`include "uvm_macros.svh"
`include "weighted_round_robin_weighted_priority_test_sequence.sv"

class weighted_round_robin_weighted_priority_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_weighted_priority_test)

  weighted_round_robin_env env;
  weighted_priority_virtual_sequencer vsqr;

  function new(string name = "weighted_round_robin_weighted_priority_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env  = weighted_round_robin_env::type_id::create("env", this);
    vsqr = weighted_priority_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    weighted_priority_test_vseq seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = weighted_priority_test_vseq::type_id::create("seq");
    seq.start(vsqr);

    phase.drop_objection(this);
  endtask
endclass

`endif // WEIGHTED_PRIORITY_TEST__SV
