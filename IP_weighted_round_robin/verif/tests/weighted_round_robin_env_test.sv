

`include "uvm_macros.svh"

`ifndef TEST__SV
`define TEST__SV

class weighted_round_robin_env_test extends uvm_test;

  `uvm_component_utils(weighted_round_robin_env_test)

  weighted_round_robin_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = weighted_round_robin_env::type_id::create("env", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    uvm_config_db #(uvm_object_wrapper)::set(this, "env.requestor_agent.requestor_seqr.main_phase",
                    "default_sequence", weighted_round_robin_base_seqr_sequence_library::get_type());

    uvm_config_db #(uvm_object_wrapper)::set(this, "env.priority_update_agent.priority_update_seqr.main_phase",
                    "default_sequence", weighted_round_robin_base_seqr_sequence_library::get_type());

  endfunction

endclass : weighted_round_robin_env_test

`endif // TEST__SV