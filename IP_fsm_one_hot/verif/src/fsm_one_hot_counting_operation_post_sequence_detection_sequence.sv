`ifndef COUNTING_OPERATION_POST_SEQUENCE_DETECTION_SEQUENCE__SV
`define COUNTING_OPERATION_POST_SEQUENCE_DETECTION_SEQUENCE__SV

`include "uvm_macros.svh"

class counting_operation_post_sequence_detection_transaction
  extends fsm_one_hot_fsm_agent_base_transaction;
  `uvm_object_utils(counting_operation_post_sequence_detection_transaction)

  function new(string name="counting_operation_post_sequence_detection_transaction");
    super.new(name);
  endfunction : new

endclass : counting_operation_post_sequence_detection_transaction


class counting_operation_post_sequence_detection_sequence extends fsm_one_hot_base_sequence;
  `uvm_object_utils(counting_operation_post_sequence_detection_sequence)
  `uvm_declare_p_sequencer(fsm_one_hot_fsm_agent_base_seqr)

  function new(string name="counting_operation_post_sequence_detection_sequence");
    super.new(name);
  endfunction : new

  task body();
    counting_operation_post_sequence_detection_transaction tr;
    localparam logic [3:0] bits_1101 = 4'b1101;

    // STEP 1) Force "1101" for consecutive cycles to trigger detection
    for (int i=0; i<4; i++) begin
      tr = counting_operation_post_sequence_detection_transaction::type_id::create(
             $sformatf("force_1101_tx_%0d", i));
      // d=1 or 0 based on bits_1101 array
      tr.d = (bits_1101[3-i] == 1) ? 1'b1 : 1'b0;
      // Keep done_counting & ack = 0 while detecting the sequence
      tr.done_counting = 1'b0;
      tr.ack           = 1'b0;

      start_item(tr);
      finish_item(tr);
    end

    // STEP 2) We expect the FSM to transition B0->B1->B2->B3->Count automatically.
    //         Meanwhile, keep driving done_counting=0 for a few extra cycles 
    //         while it’s in Count, so the FSM remains in Count.

    // For some cycles, hold done_counting=0 & ack=0
    repeat (3) begin
      tr = counting_operation_post_sequence_detection_transaction::type_id::create("hold_counting=1_phase");
      // d can be random or forced to 0/1, it doesn't matter while in Count
      tr.d             = 1'b0;
      tr.done_counting = 1'b0;  // keep count active
      tr.ack           = 1'b0;  
      start_item(tr);
      finish_item(tr);
    end

    tr = counting_operation_post_sequence_detection_transaction::type_id::create("done_counting_tx");
    tr.d             = $urandom_range(0,1); 
    tr.done_counting = 1'b0;  // cause transition out of Count
    tr.ack           = 1'b0;
    start_item(tr);
    finish_item(tr);

    // STEP 3) Now forcibly set done_counting=1 => FSM leaves Count and goes to Wait
    tr = counting_operation_post_sequence_detection_transaction::type_id::create("done_counting_tx");
    tr.d             = $urandom_range(0,1);
    tr.done_counting = 1'b1;  // cause transition out of Count
    tr.ack           = 1'b0;
    start_item(tr);
    finish_item(tr);

    // Optional STEP 4) In Wait => done=1.  Force ack=1 so the FSM returns to S
    tr = counting_operation_post_sequence_detection_transaction::type_id::create("ack_tx");
    tr.d             = $urandom_range(0,1);
    tr.done_counting = 1'b0;
    tr.ack           = 1'b1;  // leave Wait
    start_item(tr);
    finish_item(tr);

    // Optional some random traffic afterward
    repeat (2) begin
      tr = counting_operation_post_sequence_detection_transaction::type_id::
          create("post_random");
      tr.d             = 1'b0;
      tr.done_counting = 1'b0;
      tr.ack           = 1'b0;  // leave Wait
      start_item(tr);
      finish_item(tr);
    end

  endtask : body

endclass : counting_operation_post_sequence_detection_sequence

`endif // COUNTING_OPERATION_POST_SEQUENCE_DETECTION_SEQUENCE__SV
