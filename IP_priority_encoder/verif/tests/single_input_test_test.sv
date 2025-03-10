


`include "uvm_macros.svh"

// `include "priority_encoder_single_input_test_sequence.sv"

class single_input_test_test extends uvm_test;
   `uvm_component_utils(single_input_test_test)

   priority_encoder_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = priority_encoder_env::type_id::create("env", this);
   endfunction

  task run_phase(uvm_phase phase);
    single_input_test_sequence seq;
    phase.raise_objection(this);
    seq = single_input_test_sequence::type_id::create("seq");
    seq.start(env.priority_encoder_agent.base_sqr);
    phase.drop_objection(this);
  endtask
endclass