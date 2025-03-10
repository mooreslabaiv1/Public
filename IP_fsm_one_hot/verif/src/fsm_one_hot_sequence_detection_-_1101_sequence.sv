`ifndef FSM_ONE_HOT_SEQUENCE_DETECTION_1101_SEQUENCE__SV
`define FSM_ONE_HOT_SEQUENCE_DETECTION_1101_SEQUENCE__SV

`include "uvm_macros.svh"

// -----------------------------------------------------------
// Transaction class: fsm_one_hot_sequence_detection_1101_transaction
// -----------------------------------------------------------
class fsm_one_hot_sequence_detection_1101_transaction
  extends fsm_one_hot_fsm_agent_base_transaction;

  `uvm_object_utils(fsm_one_hot_sequence_detection_1101_transaction)

  // Force d, done_counting, ack to be only 0 or 1
  constraint valid_bits {
    d inside {0,1};
    done_counting inside {0,1};
    ack inside {0,1};
  }

  function new(string name="fsm_one_hot_sequence_detection_1101_transaction");
    super.new(name);
  endfunction

endclass : fsm_one_hot_sequence_detection_1101_transaction


// -----------------------------------------------------------
// Sequence class: fsm_one_hot_sequence_detection_1101_sequence
// -----------------------------------------------------------
class fsm_one_hot_sequence_detection_1101_sequence
  extends fsm_one_hot_base_sequence;

  `uvm_object_utils(fsm_one_hot_sequence_detection_1101_sequence)
  `uvm_declare_p_sequencer(fsm_one_hot_fsm_agent_base_seqr)

  function new(string name="fsm_one_hot_sequence_detection_1101_sequence");
    super.new(name);
  endfunction : new

  task body();
    fsm_one_hot_sequence_detection_1101_transaction seq_trans;

    // Forcibly send "1101" in four consecutive cycles, ensuring
    //    the FSM sees the exact sequence:
    //      cycle 1: d=1
    //      cycle 2: d=1
    //      cycle 3: d=0
    //      cycle 4: d=1

    // Force "1"
    seq_trans = fsm_one_hot_sequence_detection_1101_transaction::type_id::create("force_d1");
    seq_trans.d             = 1;
    seq_trans.done_counting = 0;
    seq_trans.ack           = 0;
    `uvm_info("SEQ_DEBUG", $sformatf(
      "Forced TX: d=%0b done_counting=%0b ack=%0b",
       seq_trans.d, seq_trans.done_counting, seq_trans.ack
    ), UVM_LOW);
    start_item(seq_trans);
    finish_item(seq_trans);

    // Force "1"
    seq_trans = fsm_one_hot_sequence_detection_1101_transaction::type_id::create("force_d2");
    seq_trans.d             = 1;
    seq_trans.done_counting = 0;
    seq_trans.ack           = 0;
    `uvm_info("SEQ_DEBUG", $sformatf(
      "Forced TX: d=%0b done_counting=%0b ack=%0b",
       seq_trans.d, seq_trans.done_counting, seq_trans.ack
    ), UVM_LOW);
    start_item(seq_trans);
    finish_item(seq_trans);

    // Force "0"
    seq_trans = fsm_one_hot_sequence_detection_1101_transaction::type_id::create("force_d3");
    seq_trans.d             = 0;
    seq_trans.done_counting = 0;
    seq_trans.ack           = 0;
    `uvm_info("SEQ_DEBUG", $sformatf(
      "Forced TX: d=%0b done_counting=%0b ack=%0b",
       seq_trans.d, seq_trans.done_counting, seq_trans.ack
    ), UVM_LOW);
    start_item(seq_trans);
    finish_item(seq_trans);

    // Force "1"
    seq_trans = fsm_one_hot_sequence_detection_1101_transaction::type_id::create("force_d4");
    seq_trans.d             = 1;
    seq_trans.done_counting = 0;
    seq_trans.ack           = 0;
    `uvm_info("SEQ_DEBUG", $sformatf(
      "Forced TX: d=%0b done_counting=%0b ack=%0b",
       seq_trans.d, seq_trans.done_counting, seq_trans.ack
    ), UVM_LOW);
    start_item(seq_trans);
    finish_item(seq_trans);

    // dummy last "0" (optional)
    seq_trans = fsm_one_hot_sequence_detection_1101_transaction::type_id::create("force_d5");
    seq_trans.d             = 0;
    seq_trans.done_counting = 0;
    seq_trans.ack           = 0;
    `uvm_info("SEQ_DEBUG", $sformatf(
      "Forced TX: d=%0b done_counting=%0b ack=%0b",
       seq_trans.d, seq_trans.done_counting, seq_trans.ack
    ), UVM_LOW);
    start_item(seq_trans);
    finish_item(seq_trans);

  endtask : body

endclass : fsm_one_hot_sequence_detection_1101_sequence

`endif // FSM_ONE_HOT_SEQUENCE_DETECTION_1101_SEQUENCE__SV
