class TestCase2_IncorrectParity_test extends uvm_test;
  `uvm_component_utils(TestCase2_IncorrectParity_test)

  serialDP_env env;

  // Declarations
  function new(string name="TestCase2_IncorrectParity_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = serialDP_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    serialDP_TestCase2_IncorrectParity_sequence seq;
    begin
      super.run_phase(phase);

      phase.raise_objection(this, "TestCase2_IncorrectParity_test Starting");
      seq = serialDP_TestCase2_IncorrectParity_sequence::type_id::create("seq");
      seq.start(env.serial_agent.base_sqr);
      #100ms;
      phase.drop_objection(this, "TestCase2_IncorrectParity_test Complete");
    end
  endtask

endclass : TestCase2_IncorrectParity_test