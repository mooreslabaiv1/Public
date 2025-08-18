


class serial_stop_bit_error_detection_test_sequence extends serial_base_sequence;

  `uvm_object_utils(serial_stop_bit_error_detection_test_sequence)

  function new(string name="serial_stop_bit_error_detection_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    // Declare everything at start
    serial_trans_item start_tr;
    serial_trans_item data_tr;
    serial_trans_item parity_tr;
    serial_trans_item stop_tr;
    bit [7:0] local_data_bits;

    // Start bit (forcing 0)
    start_tr = serial_trans_item::type_id::create("start_tr");
    start_tr.in = 0;
    start_item(start_tr);
    finish_item(start_tr);

    // Randomize some data bits
    if(!std::randomize(local_data_bits)) begin
      `uvm_error(get_type_name(), "Randomization failed for local_data_bits");
    end

    // Send 8 data bits
    for (int i = 0; i < 8; i++) begin
      data_tr = serial_trans_item::type_id::create($sformatf("data_tr_%0d", i));
      data_tr.in = local_data_bits[i];
      start_item(data_tr);
      finish_item(data_tr);
    end

    // Send a parity bit (odd parity)
    parity_tr = serial_trans_item::type_id::create("parity_tr");
    parity_tr.in = ^local_data_bits ^ 1;
    start_item(parity_tr);
    finish_item(parity_tr);

    // Force an incorrect stop bit (0 instead of 1)
    stop_tr = serial_trans_item::type_id::create("stop_tr");
    stop_tr.in = 0;
    start_item(stop_tr);
    finish_item(stop_tr);
  endtask

endclass : serial_stop_bit_error_detection_test_sequence