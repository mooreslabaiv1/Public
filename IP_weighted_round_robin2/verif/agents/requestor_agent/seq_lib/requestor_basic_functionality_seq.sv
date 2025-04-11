`ifndef REQUESTOR_BASIC_FUNCTIONALITY_SEQ__SV
`define REQUESTOR_BASIC_FUNCTIONALITY_SEQ__SV

class requestor_basic_functionality_sequence extends uvm_sequence #(requestor_trans_item);

    // Factory Registration
    `uvm_object_utils(requestor_basic_functionality_sequence)

    // Constructor
    function new(string name = "requestor_basic_functionality_seq");
        super.new(name);
    endfunction : new

    //******************************************************************************
    // Body
    //******************************************************************************
    virtual task body();
        requestor_trans_item req;
        `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()),
                  UVM_LOW)
        repeat (80) begin

            req = requestor_trans_item::type_id::create("req");
            req.req = '1;  // All requestors are requesting.
            start_item(req);
            finish_item(req);
        end
    endtask : body

endclass : requestor_basic_functionality_sequence

`endif  // REQUESTOR_BASIC_FUNCTIONALITY_SEQ__SV
