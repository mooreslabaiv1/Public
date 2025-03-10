


`include "uvm_macros.svh"

class fsm_seek_detect_asyncresettest_sequence extends base_sequence;
  `uvm_object_utils(fsm_seek_detect_asyncresettest_sequence)

  function new(string name="fsm_seek_detect_asyncresettest_sequence");
    super.new(name);
  endfunction

  task body();
    fsm_seek_detect_fsm_seek_detect_agent_base_transaction seq_item;
    bit success;
    seq_item = fsm_seek_detect_fsm_seek_detect_agent_base_transaction::type_id::create("seq_item");
    success = 0;

    // Step 1: Drive x=1 to move to next state
    seq_item.x = 1;
    seq_item.aresetn = 1;
    start_item(seq_item);
    finish_item(seq_item);

    // Step 2: Assert asynchronous reset (aresetn=0)
    seq_item.x = 1;
    seq_item.aresetn = 0;
    start_item(seq_item);
    finish_item(seq_item);

    // Step 3: Deassert reset (aresetn=1) and check FSM returns to S0, z=0
    seq_item.x = 1;
    seq_item.aresetn = 1;
    start_item(seq_item);
    finish_item(seq_item);
  endtask

endclass