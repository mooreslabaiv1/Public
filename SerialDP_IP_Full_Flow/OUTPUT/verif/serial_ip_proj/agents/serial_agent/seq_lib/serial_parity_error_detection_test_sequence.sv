

class serial_parity_error_detection_test_sequence extends serial_base_sequence;

  `uvm_object_utils(serial_parity_error_detection_test_sequence)

  rand bit [7:0] data_bits;
  rand bit       parity_bit;

  // Constrain the data bits and parity bit so that the total number of ones is even
  constraint even_parity_c {
    (^data_bits ^ parity_bit) == 1'b0;
  }

  function new(string name="serial_parity_error_detection_test_sequence");
    super.new(name);
  endfunction : new

  task body();
    serial_trans_item start_tr;
    serial_trans_item data_tr;
    serial_trans_item parity_tr;
    serial_trans_item stop_tr;

    // Start bit (always 0)
    start_tr = serial_trans_item::type_id::create("start_tr");
    start_tr.in = 0;
    start_item(start_tr);
    finish_item(start_tr);

    // Randomize data bits and parity bit for even parity
    if(!this.randomize()) begin
      `uvm_error(get_type_name(), "Randomization failed for even parity error test transaction")
    end

    // Send 8 data bits
    for (int i = 0; i < 8; i++) begin
      data_tr = serial_trans_item::type_id::create($sformatf("data_tr_%0d", i));
      data_tr.in = data_bits[i];
      start_item(data_tr);
      finish_item(data_tr);
    end

    // Send parity bit
    parity_tr = serial_trans_item::type_id::create("parity_tr");
    parity_tr.in = parity_bit;
    start_item(parity_tr);
    finish_item(parity_tr);

    // Stop bit (always 1)
    stop_tr = serial_trans_item::type_id::create("stop_tr");
    stop_tr.in = 1;
    start_item(stop_tr);
    finish_item(stop_tr);
  endtask : body

endclass : serial_parity_error_detection_test_sequence