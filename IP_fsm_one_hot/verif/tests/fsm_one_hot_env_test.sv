


`ifndef TEST__SV
`define TEST__SV

typedef class fsm_one_hot_env;

class fsm_one_hot_env_test extends uvm_test;

  `uvm_component_utils(fsm_one_hot_env_test)

  fsm_one_hot_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_one_hot_env::type_id::create("env", this);
    
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.fsm_agent.base_sqr.main_phase",
                    "default_sequence", fsm_one_hot_base_seqr_sequence_library::get_type());

  endfunction

endclass : fsm_one_hot_env_test

`endif //TEST__SV