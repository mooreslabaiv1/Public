`ifndef RANDOMIZED_STRESS_TEST__SV
`define RANDOMIZED_STRESS_TEST__SV

`include "uvm_macros.svh"
// Include the multi-agent concurrency sequence
`include "weighted_round_robin_randomized_stress_test_sequence.sv"

class weighted_round_robin_randomized_stress_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_randomized_stress_test)

  weighted_round_robin_env                 env;
  randomized_stress_virtual_sequencer      vsqr;

  function new(string name = "weighted_round_robin_randomized_stress_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // 2-agent environment
    env = weighted_round_robin_env::type_id::create("env", this);

    // Virtual sequencer
    vsqr = randomized_stress_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    weighted_round_robin_randomized_stress_test_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = weighted_round_robin_randomized_stress_test_sequence::type_id
          ::create("random_stress_seq");
    seq.start(vsqr);

    phase.drop_objection(this);
  endtask
endclass

`endif // RANDOMIZED_STRESS_TEST__SV
