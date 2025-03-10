`ifndef PRIORITY_ENCODER_RESET_FUNCTIONALITY_TEST_SEQUENCE_SV
`define PRIORITY_ENCODER_RESET_FUNCTIONALITY_TEST_SEQUENCE_SV

class priority_encoder_reset_functionality_test_transaction extends priority_encoder_priority_encoder_agent_base_transaction;
  `uvm_object_utils(priority_encoder_reset_functionality_test_transaction)

  function new(string name="priority_encoder_reset_functionality_test_transaction");
    super.new(name);
  endfunction
endclass : priority_encoder_reset_functionality_test_transaction

class priority_encoder_reset_base_sequence extends uvm_sequence #(priority_encoder_priority_encoder_agent_base_transaction);
  `uvm_object_utils(priority_encoder_reset_base_sequence)

  function new(string name = "priority_encoder_reset_base_sequence");
    super.new(name);
  endfunction

  task body();
  endtask
endclass : priority_encoder_reset_base_sequence

class reset_functionality_test_sequence extends priority_encoder_reset_base_sequence;
  `uvm_object_utils(reset_functionality_test_sequence)
  priority_encoder_reset_functionality_test_transaction tr;

  function new(string name = "reset_functionality_test_sequence");
    super.new(name);
  endfunction : new

  task body();
    tr = priority_encoder_reset_functionality_test_transaction::type_id::create("tr");

    tr.sa = 8'hA;
    tr.reset_val = 0;
    start_item(tr);
    finish_item(tr);

    tr.sa = 8'hA;
    tr.reset_val = 1;
    start_item(tr);
    finish_item(tr);

    tr.sa = 8'hA;
    tr.reset_val = 1;
    start_item(tr);
    finish_item(tr);

  endtask : body

endclass : reset_functionality_test_sequence

`endif // PRIORITY_ENCODER_RESET_FUNCTIONALITY_TEST_SEQUENCE_SV