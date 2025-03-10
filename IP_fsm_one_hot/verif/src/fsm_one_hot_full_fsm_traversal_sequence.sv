`ifndef FSM_ONE_HOT_FULL_FSM_TRAVERSAL_SEQUENCE_SV
`define FSM_ONE_HOT_FULL_FSM_TRAVERSAL_SEQUENCE_SV

`include "uvm_macros.svh"

class full_fsm_traversal_tr extends fsm_one_hot_fsm_agent_base_transaction;
  `uvm_object_utils(full_fsm_traversal_tr)

  function new(string name="full_fsm_traversal_tr");
    super.new(name);
  endfunction

endclass : full_fsm_traversal_tr

class full_fsm_traversal_sequence extends fsm_one_hot_base_sequence;
  `uvm_object_utils(full_fsm_traversal_sequence)
  `uvm_declare_p_sequencer(fsm_one_hot_fsm_agent_base_seqr)

  function new(string name="full_fsm_traversal_sequence");
    super.new(name);
  endfunction

  task body();
    full_fsm_traversal_tr tr;
    localparam logic [7:0] bits_01011101 = 8'b01011101;

    // STEP 1) Force "01011101" for consecutive cycles to trigger detection
    for (int i=0; i<8; i++) begin
      tr = full_fsm_traversal_tr::type_id::create(
             $sformatf("force_01011101_tx_%0d", i));
      // d=1 or 0 based on bits_01011101 array
      tr.d = (bits_01011101[7-i] == 1) ? 1'b1 : 1'b0;
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
      tr = full_fsm_traversal_tr::type_id::create("hold_counting");
      // d can be random or forced to 0/1, it doesn't matter while in Count
      tr.d             = $urandom_range(0,1);
      tr.done_counting = 1'b0;  // keep count active
      tr.ack           = 1'b0;  
      start_item(tr);
      finish_item(tr);
    end

    // STEP 3) Stay in Count State
    repeat (2) begin
      tr = full_fsm_traversal_tr::type_id::create("done_counting_tx");
      tr.d             = $urandom_range(0,1); 
      tr.done_counting = 1'b0;  // cause transition out of Count
      tr.ack           = 1'b0;
      start_item(tr);
      finish_item(tr);
    end

    // STEP 4) Now forcibly set done_counting=1 => FSM leaves Count and goes to Wait
    tr = full_fsm_traversal_tr::type_id::create("done_counting_tx");
    tr.d             = $urandom_range(0,1);
    tr.done_counting = 1'b1;  // cause transition out of Count
    tr.ack           = 1'b0;
    start_item(tr);
    finish_item(tr);

    // STEP 5) Stay in Wait State
    tr = full_fsm_traversal_tr::type_id::create("done_counting_tx");
    tr.d             = $urandom_range(0,1); 
    tr.done_counting = 1'b0;  // cause transition out of Count
    tr.ack           = 1'b0;
    start_item(tr);
    finish_item(tr);

    // STEP 6) In Wait => done=1.  Force ack=1 so the FSM returns to S
    tr = full_fsm_traversal_tr::type_id::create("ack_tx");
    tr.d             = $urandom_range(0,1);
    tr.done_counting = 1'b0;
    tr.ack           = 1'b1;  // leave Wait
    start_item(tr);
    finish_item(tr);

    // STEP 7) Optional some random traffic afterward
    repeat (2) begin
      tr = full_fsm_traversal_tr::type_id::
          create("post_random");
      tr.d             = $urandom_range(0,1);
      tr.done_counting = 1'b0;
      tr.ack           = 1'b0;  // leave Wait
      start_item(tr);
      finish_item(tr);
    end

  endtask : body

endclass : full_fsm_traversal_sequence

`endif // FSM_ONE_HOT_FULL_FSM_TRAVERSAL_SEQUENCE_SV