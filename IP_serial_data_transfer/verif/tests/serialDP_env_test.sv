`ifndef TEST__SV
`define TEST__SV

typedef class serialDP_env;

class serialDP_env_test extends uvm_test;

  `uvm_component_utils(serialDP_env_test)

  serialDP_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = serialDP_env::type_id::create("env", this);
    
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.serial_agent.base_sqr.main_phase",
                    "default_sequence", serialDP_base_seqr_sequence_library::get_type());

  endfunction

endclass : serialDP_env_test

`endif //TEST__SV