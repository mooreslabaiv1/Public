

`ifndef TEST__SV
`define TEST__SV

typedef class priority_encoder_env;

class priority_encoder_env_test extends uvm_test;

  `uvm_component_utils(priority_encoder_env_test)

  priority_encoder_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = priority_encoder_env::type_id::create("env", this);
    
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.priority_encoder_agent.base_sqr.main_phase",
                    "default_sequence", priority_encoder_base_seqr_sequence_library::get_type());

  endfunction

endclass : priority_encoder_env_test

`endif //TEST__SV