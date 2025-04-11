`ifndef PRIO_UPDATE_TRANS_ITEM__SV
`define PRIO_UPDATE_TRANS_ITEM__SV

class prio_update_trans_item extends uvm_sequence_item;

    //******************************************************************************
    // Variables
    //******************************************************************************
    logic ack;
    rand logic [3:0] prio;
    rand logic [4:0] prio_id;
    rand logic prio_upt;

    //******************************************************************************
    // Constraints
    //******************************************************************************
    // <Optional> ToDo: Add constraint blocks to prevent error injection

    //******************************************************************************
    // Factory registration
    //******************************************************************************
    `uvm_object_utils_begin(prio_update_trans_item)
        `uvm_field_int(ack, UVM_ALL_ON)
        `uvm_field_int(prio, UVM_ALL_ON)
        `uvm_field_int(prio_id, UVM_ALL_ON)
        `uvm_field_int(prio_upt, UVM_ALL_ON)
    `uvm_object_utils_end

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "prio_update_trans_item");
        super.new(name);
    endfunction : new

endclass : prio_update_trans_item

`endif  // PRIO_UPDATE_TRANS_ITEM__SV
