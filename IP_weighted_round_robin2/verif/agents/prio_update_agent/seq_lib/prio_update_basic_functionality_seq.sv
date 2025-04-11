`ifndef PRIO_UPDATE_BASIC_FUNCTIONALITY_SEQ__SV
`define PRIO_UPDATE_BASIC_FUNCTIONALITY_SEQ__SV

class prio_update_basic_functionality_sequence extends uvm_sequence #(prio_update_trans_item);

    // Factory Registration
    `uvm_object_utils(prio_update_basic_functionality_sequence)

    // Constructor
    function new(string name = "prio_update_basic_functionality_seq");
        super.new(name);
    endfunction : new

    //******************************************************************************
    // Body
    //******************************************************************************
    virtual task body();
        prio_update_trans_item req;

        req = prio_update_trans_item::type_id::create("req");

        `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()),
                  UVM_LOW)

        for (int i = 0; i < 32; i++) begin
            if (!req.randomize() with {
                    prio_upt == 1;  // ensure we always update
                    prio == 10;
                    prio_id == i;
                }) begin
                `uvm_error("RAND_FAIL", "Failed to randomize prio transaction")
            end
            start_item(req);
            finish_item(req);
        end

        if (!req.randomize() with {
                prio_upt == 0;  // ensure we always update
                prio == 0;
                prio_id == 0;
            }) begin
            `uvm_error("RAND_FAIL", "Failed to randomize prio transaction")
        end
        start_item(req);
        finish_item(req);

    endtask : body

endclass : prio_update_basic_functionality_sequence

`endif  // PRIO_UPDATE_BASIC_FUNCTIONALITY_SEQ__SV
