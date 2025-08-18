
`ifndef SERIAL_TRANS_ITEM__SV
`define SERIAL_TRANS_ITEM__SV

class serial_trans_item extends uvm_sequence_item;

    //******************************************************************************
    // Variables
    //******************************************************************************
    rand logic [7:0] data_bits;
    rand logic  in;
    logic [7:0] out_byte;
    logic  done;

    //******************************************************************************
    // Constraints
    //******************************************************************************
    // <Optional> ToDo: Add constraint blocks to prevent error injection

    //******************************************************************************
    // Factory registration
    //******************************************************************************
    `uvm_object_utils_begin(serial_trans_item)
        `uvm_field_int(data_bits, UVM_ALL_ON)
        `uvm_field_int(in, UVM_ALL_ON)
        `uvm_field_int(out_byte, UVM_ALL_ON)
        `uvm_field_int(done, UVM_ALL_ON)
    `uvm_object_utils_end

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "serial_trans_item");
        super.new(name);
    endfunction : new

endclass : serial_trans_item

`endif  // SERIAL_TRANS_ITEM__SV