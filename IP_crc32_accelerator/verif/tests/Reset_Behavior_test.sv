

`ifndef RESET_BEHAVIOR_TEST__SV
`define RESET_BEHAVIOR_TEST__SV

typedef class crc32_accelerator_p_env;

class Reset_Behavior_test extends uvm_test;

  `uvm_component_utils(Reset_Behavior_test)

  crc32_accelerator_p_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = crc32_accelerator_p_env::type_id::create("env", this);

    uvm_config_db #(uvm_object_wrapper)::set(this, "env.crc32_accelerator_agent.base_sqr.main_phase",
                    "default_sequence", Reset_Behavior::type_id::get());
  endfunction

endclass : Reset_Behavior_test

`endif // RESET_BEHAVIOR_TEST__SV