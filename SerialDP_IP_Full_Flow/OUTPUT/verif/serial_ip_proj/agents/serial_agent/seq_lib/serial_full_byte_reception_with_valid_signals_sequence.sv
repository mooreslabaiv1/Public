


class serial_full_byte_reception_with_valid_signals_sequence extends serial_base_sequence;

  `uvm_object_utils(serial_full_byte_reception_with_valid_signals_sequence)

  function new(string name="serial_full_byte_reception_with_valid_signals_sequence");
    super.new(name);
  endfunction

  virtual task body();
    serial_trans_item trans;

    // Generate a single constrained-random transaction
    trans = serial_trans_item::type_id::create("trans");
    start_item(trans);
    assert(trans.randomize()) else
      $error("Randomization failed for trans in full_byte_reception_with_valid_signals_sequence.");
    finish_item(trans);

    // Additional transactions or stimulus can be added here if needed

  endtask : body

endclass : serial_full_byte_reception_with_valid_signals_sequence