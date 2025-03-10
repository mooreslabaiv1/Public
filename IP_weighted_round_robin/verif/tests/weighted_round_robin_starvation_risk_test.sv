`ifndef STARVATION_RISK_TEST__SV
`define STARVATION_RISK_TEST__SV

`include "uvm_macros.svh"
`include "weighted_round_robin_starvation_risk_test_sequence.sv"

class weighted_round_robin_starvation_risk_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_starvation_risk_test)

  weighted_round_robin_env                   env;
  starvation_risk_test_virtual_sequencer     vsqr;

  function new(string name = "weighted_round_robin_starvation_risk_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create environment with two agents:
    // 1) requestor_agent
    // 2) priority_update_agent
    env  = weighted_round_robin_env::type_id::create("env", this);

    // Create the virtual sequencer referencing both sub-sequencers
    vsqr = starvation_risk_test_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Hook up the agents to the virtual sequencer
    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    starvation_risk_test_sequence seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    // Start the multi-agent concurrency sequence

    seq = starvation_risk_test_sequence::type_id::create("starvation_risk_test_sequence");
    seq.start(vsqr);

    phase.drop_objection(this);
  endtask
endclass

`endif // STARVATION_RISK_TEST__SV
