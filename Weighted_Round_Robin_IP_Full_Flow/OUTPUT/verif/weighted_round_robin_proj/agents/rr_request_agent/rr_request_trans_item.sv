`ifndef RR_REQUEST_TRANS_ITEM__SV
`define RR_REQUEST_TRANS_ITEM__SV

class rr_request_trans_item extends uvm_sequence_item;

    //******************************************************************************
    // Variables
    //******************************************************************************
    rand logic [31:0] req;
    rand logic  ack;

    //******************************************************************************
    // Constraints
    //******************************************************************************
    // <Optional> ToDo: Add constraint blocks to prevent error injection

    //******************************************************************************
    // Factory registration
    //******************************************************************************
    `uvm_object_utils_begin(rr_request_trans_item)
    `uvm_field_int(req, UVM_ALL_ON)
    `uvm_field_int(ack, UVM_ALL_ON)
    `uvm_object_utils_end

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "rr_request_trans_item");
        super.new(name);
    endfunction : new

endclass : rr_request_trans_item

`endif  // RR_REQUEST_TRANS_ITEM__SV