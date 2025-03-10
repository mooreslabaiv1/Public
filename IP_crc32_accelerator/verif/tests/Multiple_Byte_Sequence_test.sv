

`ifndef MULTIPLE_BYTE_SEQUENCE_TEST__SV
`define MULTIPLE_BYTE_SEQUENCE_TEST__SV

typedef class crc32_accelerator_p_env;

class Multiple_Byte_Sequence_test extends uvm_test;

  `uvm_component_utils(Multiple_Byte_Sequence_test)

  crc32_accelerator_p_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = crc32_accelerator_p_env::type_id::create("env", this);
    
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.crc32_accelerator_agent.base_sqr.main_phase",
                    "default_sequence", Multiple_Byte_Sequence::type_id::get());
  endfunction

endclass : Multiple_Byte_Sequence_test

`endif // MULTIPLE_BYTE_SEQUENCE_TEST__SV