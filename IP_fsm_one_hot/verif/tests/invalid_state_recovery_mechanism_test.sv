`include "uvm_macros.svh"
`include "fsm_one_hot_invalid_state_recovery_mechanism_sequence.sv"


class invalid_state_recovery_mechanism_test extends fsm_one_hot_base_test;
  `uvm_component_utils(invalid_state_recovery_mechanism_test)

  function new(string name="invalid_state_recovery_mechanism_test", 
               uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    // 1) Start the normal sequence
    fsm_one_hot_invalid_state_recovery_mechanism_sequence seq;
    seq = fsm_one_hot_invalid_state_recovery_mechanism_sequence::type_id::create("seq");
    seq.start(p_sequencer);

    // 2) Force the DUT's state register to an invalid (two bits high) pattern
    //    *** Adjust the path below to match your actual hierarchy! ***
    `uvm_info("INVALID_STATE_RECOVERY", 
      "Forcing FSM state to invalid combination (two bits = 1) ...", UVM_LOW)

    force uvm_test_top.env.fsm_if_inst.dut.state = 10'b1100000000;

    // 3) Wait one clock so the FSM sees this forced invalid state
    @(posedge uvm_test_top.env.fsm_if_inst.clk);

    // 4) Release the force; we expect the FSM to recover to S on the next clock
    `uvm_info("INVALID_STATE_RECOVERY", 
      "Releasing force; expecting FSM to transition back to S next cycle ...", UVM_LOW)

    release uvm_test_top.env.fsm_if_inst.dut.state;

    // 5) Wait another clock or two
    @(posedge uvm_test_top.env.fsm_if_inst.clk);
    repeat (2) @(posedge uvm_test_top.env.fsm_if_inst.clk);

    `uvm_info("INVALID_STATE_RECOVERY", 
      "Invalid State Recovery test is complete.", UVM_LOW)

    phase.drop_objection(this);
  endtask : run_phase

endclass : invalid_state_recovery_mechanism_test
