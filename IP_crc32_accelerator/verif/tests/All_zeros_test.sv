

`ifndef ALL_ZEROS_TEST__SV
`define ALL_ZEROS_TEST__SV

typedef class crc32_accelerator_p_env;

class All_zeros_test extends uvm_test;

  `uvm_component_utils(All_zeros_test)

  crc32_accelerator_p_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = crc32_accelerator_p_env::type_id::create("env", this);

    uvm_config_db #(uvm_object_wrapper)::set(this, "env.crc32_accelerator_agent.base_sqr.main_phase",
                    "default_sequence", All_zeros::type_id::get());
  endfunction

endclass : All_zeros_test

`endif // ALL_ZEROS_TEST__SV