

`ifndef TEST__SV
`define TEST__SV

typedef class fsm_seek_detect_env;

class fsm_seek_detect_env_test extends uvm_test;

  `uvm_component_utils(fsm_seek_detect_env_test)

  fsm_seek_detect_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fsm_seek_detect_env::type_id::create("env", this);
    
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.fsm_seek_detect_agent.base_sqr.main_phase",
                    "default_sequence", fsm_seek_detect_base_seqr_sequence_library::get_type());

  endfunction

endclass : fsm_seek_detect_env_test

`endif //TEST__SV