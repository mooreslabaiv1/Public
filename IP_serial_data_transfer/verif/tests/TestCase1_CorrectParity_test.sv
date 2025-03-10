class TestCase1_CorrectParity_test extends uvm_test;

  `uvm_component_utils(TestCase1_CorrectParity_test)
  
  serialDP_env env;

  function new(string name = "TestCase1_CorrectParity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = serialDP_env::type_id::create("env", this);
    // Configure UVM to use TestCase1_CorrectParity_sequence on main_phase
    uvm_config_db #(uvm_object_wrapper)::set(this,
                                             "env.serial_agent.base_sqr.main_phase",
                                             "default_sequence",
                                             TestCase1_CorrectParity_sequence::type_id::get());
  endfunction : build_phase

endclass : TestCase1_CorrectParity_test