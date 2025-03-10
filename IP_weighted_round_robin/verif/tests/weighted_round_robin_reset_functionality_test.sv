`ifndef RESET_FUNCTIONALITY_TEST__SV
`define RESET_FUNCTIONALITY_TEST__SV

class weighted_round_robin_reset_functionality_test extends uvm_test;
  `uvm_component_utils(weighted_round_robin_reset_functionality_test)

  weighted_round_robin_env env;
  reset_func_virtual_sequencer vsqr;

  function new(string name = "weighted_round_robin_reset_functionality_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env  = weighted_round_robin_env::type_id::create("env", this);
    vsqr = reset_func_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vsqr.requestor_seqr       = env.requestor_agent.requestor_seqr;
    vsqr.priority_update_seqr = env.priority_update_agent.priority_update_seqr;
  endfunction

  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);

    // Toggle reset from here if needed:
    // e.g. env.requestor_if.rst=1; wait some time, rst=0, etc.
    // Meanwhile, the sub-sequences run in parallel.

    reset_func_test_vseq seq;
    seq = reset_func_test_vseq::type_id::create("seq");
    seq.start(vsqr);

    phase.drop_objection(this);
  endtask
endclass

`endif // RESET_FUNCTIONALITY_TEST__SV