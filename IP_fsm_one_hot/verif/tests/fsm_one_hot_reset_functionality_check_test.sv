`ifndef FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_TEST__SV
`define FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_TEST__SV

`include "uvm_macros.svh"
`include "fsm_one_hot_reset_functionality_check_sequence.sv"

class fsm_one_hot_reset_functionality_check_test extends uvm_test;
  `uvm_component_utils(fsm_one_hot_reset_functionality_check_test)

  fsm_one_hot_env env;

  function new(string name="fsm_one_hot_reset_functionality_check_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = fsm_one_hot_env::type_id::create("env", this);

    uvm_config_db #(uvm_object_wrapper)::set(
      this,
      "env.fsm_agent.base_sqr.main_phase",
      "default_sequence",
      fsm_one_hot_reset_functionality_check_sequence::type_id::get()
    );
  endfunction : build_phase

endclass : fsm_one_hot_reset_functionality_check_test

`endif // FSM_ONE_HOT_RESET_FUNCTIONALITY_CHECK_TEST__SV
