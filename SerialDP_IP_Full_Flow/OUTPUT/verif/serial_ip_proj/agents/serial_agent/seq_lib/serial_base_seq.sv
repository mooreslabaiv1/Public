`ifndef SERIAL_BASE_SEQ__SV
`define SERIAL_BASE_SEQ__SV

class serial_base_sequence extends uvm_sequence #(serial_trans_item);

  // Factory Registration
  `uvm_object_utils(serial_base_sequence)

  // Constructor
  function new(string name = "serial_base_seq");
    super.new(name);
  endfunction : new

  //******************************************************************************
  // Body
  //******************************************************************************
  virtual task body();
    `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()), UVM_LOW)
    repeat (80) begin
      `uvm_do(req);
    end
  endtask : body

endclass : serial_base_sequence

`endif  // SERIAL_BASE_SEQ__SV