`ifndef FSM_ONE_HOT_INVALID_STATE_RECOVERY_MECHANISM_SEQUENCE__SV
`define FSM_ONE_HOT_INVALID_STATE_RECOVERY_MECHANISM_SEQUENCE__SV

`include "uvm_macros.svh"

// Simple transaction class
class invalid_state_recovery_mechanism_transaction 
  extends fsm_one_hot_fsm_agent_base_transaction;
  `uvm_object_utils(invalid_state_recovery_mechanism_transaction)

  function new(string name="invalid_state_recovery_mechanism_transaction");
    super.new(name);
  endfunction
endclass : invalid_state_recovery_mechanism_transaction


// The sequence: drives a minimal transaction, but the real "invalid force" is done in the test
class fsm_one_hot_invalid_state_recovery_mechanism_sequence
  extends fsm_one_hot_base_sequence;

  `uvm_object_utils(fsm_one_hot_invalid_state_recovery_mechanism_sequence)

  function new(string name="fsm_one_hot_invalid_state_recovery_mechanism_sequence");
    super.new(name);
  endfunction : new

  task body();
    // Create & start a single transaction (you can add more if desired)
    invalid_state_recovery_mechanism_transaction tx;
    tx = invalid_state_recovery_mechanism_transaction::type_id::create("tx");

    start_item(tx);
    finish_item(tx);

    // You could add more transaction logic here if needed.
  endtask : body

endclass : fsm_one_hot_invalid_state_recovery_mechanism_sequence

`endif // FSM_ONE_HOT_INVALID_STATE_RECOVERY_MECHANISM_SEQUENCE__SV
