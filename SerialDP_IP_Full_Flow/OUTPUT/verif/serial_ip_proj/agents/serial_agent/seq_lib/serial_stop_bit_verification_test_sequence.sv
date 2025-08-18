


class serial_stop_bit_verification_test_sequence extends serial_base_sequence;
  `uvm_object_utils(serial_stop_bit_verification_test_sequence)

  rand serial_trans_item trans;

  function new(string name="serial_stop_bit_verification_test_sequence");
    super.new(name);
  endfunction

  task body();
    trans = serial_trans_item::type_id::create("trans");
    void'(trans.randomize());
    start_item(trans);
    finish_item(trans);
  endtask

endclass