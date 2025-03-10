`ifndef GRANT_ACK_TEST_SV
`define GRANT_ACK_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

// Include the multi-agent sequences from the sequences file
`include "weighted_round_robin_grant_ack_test_sequence.sv"

class weighted_round_robin_grant_ack_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_grant_ack_test)

  weighted_round_robin_env    env;
  grant_ack_virtual_sequencer vsqr;

  function new(string name = "weighted_round_robin_grant_ack_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env  = weighted_round_robin_env::type_id::create("env", this);

    // Create virtual sequencer
    vsqr = grant_ack_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Hook sub-sequencers
    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task run_phase(uvm_phase phase);
    grant_ack_test_vseq seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    seq = grant_ack_test_vseq::type_id::create("grant_ack_test_vseq");
    seq.start(vsqr);  // Start the multi-agent virtual sequence

    phase.drop_objection(this);
  endtask
endclass

`endif // GRANT_ACK_TEST_SV
