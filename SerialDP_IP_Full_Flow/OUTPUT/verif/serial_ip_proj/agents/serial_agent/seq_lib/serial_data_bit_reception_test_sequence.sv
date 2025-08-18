

class serial_data_bit_reception_test_sequence extends serial_base_sequence;

  `uvm_object_utils(serial_data_bit_reception_test_sequence)

  rand bit [7:0] data_field;

  constraint data_field_c {
    // Example constraint can be expanded as needed
    data_field inside {[0:255]};
  }

  virtual task body();
    serial_trans_item tx;
    
    // Create and randomize a single transaction
    tx = serial_trans_item::type_id::create("tx");
    if(!randomize(data_field)) begin
      `uvm_error(get_type_name(), "Randomization failed for data_field")
    end

    // Fill the data bits into the transaction
    tx.data_bits = data_field;

    start_item(tx);
    finish_item(tx);
  endtask : body

endclass : serial_data_bit_reception_test_sequence