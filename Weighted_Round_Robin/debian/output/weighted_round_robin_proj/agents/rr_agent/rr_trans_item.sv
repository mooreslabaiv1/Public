`ifndef RR_TRANS_ITEM__SV
`define RR_TRANS_ITEM__SV

class rr_trans_item extends uvm_sequence_item;

    //******************************************************************************
    // Variables
    //******************************************************************************
    rand logic [31:0] req;
    rand logic  ack;
    logic [31:0] gnt_w;
    logic [4:0] gnt_id;

    //******************************************************************************
    // Constraints
    //******************************************************************************
    // <Optional> ToDo: Add constraint blocks to prevent error injection

    //******************************************************************************
    // Factory registration
    //******************************************************************************
    `uvm_object_utils_begin(rr_trans_item)
    `uvm_field_int(req, UVM_ALL_ON)
    `uvm_field_int(ack, UVM_ALL_ON)
    `uvm_field_int(gnt_w, UVM_ALL_ON)
    `uvm_field_int(gnt_id, UVM_ALL_ON)
    `uvm_object_utils_end

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "rr_trans_item");
        super.new(name);
    endfunction : new

endclass : rr_trans_item

`endif  // RR_TRANS_ITEM__SV