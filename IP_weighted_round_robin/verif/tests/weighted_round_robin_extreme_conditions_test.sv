`ifndef EXTREME_CONDITIONS_TEST__SV
`define EXTREME_CONDITIONS_TEST__SV

`include "uvm_macros.svh"

// Include the multi-agent concurrency sequence
`include "weighted_round_robin_extreme_conditions_test_sequence.sv"

class weighted_round_robin_extreme_conditions_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_extreme_conditions_test)

  weighted_round_robin_env                env;
  extreme_conditions_virtual_sequencer    vsqr;

  function new(string name = "weighted_round_robin_extreme_conditions_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create environment with:
    //   requestor_agent, priority_update_agent
    env  = weighted_round_robin_env::type_id::create("env", this);

    // Create the virtual sequencer referencing both sub-sequencers
    vsqr = extreme_conditions_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Hook up to environment's agents
    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    extreme_conditions_test_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = extreme_conditions_test_sequence::type_id::create("extreme_conditions_test_sequence");
    seq.start(vsqr);

    phase.drop_objection(this);
  endtask
endclass

`endif // EXTREME_CONDITIONS_TEST__SV
