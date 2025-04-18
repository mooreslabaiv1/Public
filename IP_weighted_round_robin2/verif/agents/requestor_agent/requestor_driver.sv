`ifndef REQUESTOR_DRIVER__SV
`define REQUESTOR_DRIVER__SV

class requestor_driver extends uvm_driver #(requestor_trans_item);

    // Register with factory
    `uvm_component_utils(requestor_driver);

    virtual requestor_if drv_if;

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "requestor_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //*****************************************************************************
    // Build Phase
    //*****************************************************************************
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    //******************************************************************************
    // Connect Phase
    //******************************************************************************
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    //******************************************************************************
    // End of Elaboration Phase
    //******************************************************************************
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        if (drv_if == null)
            `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");
    endfunction : end_of_elaboration_phase

    //******************************************************************************
    // Run Phase
    //******************************************************************************  
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            requestor_trans_item tr;
            seq_item_port.get_next_item(tr);
            `uvm_info(get_full_name(), $sformatf("Starting transaction in %s ...", get_type_name()),
                      UVM_LOW)
            fork
                tx_driver(tr);
                begin
                    @(posedge drv_if.rst);
                    `uvm_info(get_full_name(), "RESET DETECTED ...", UVM_LOW)
                end
            join_any
            disable fork;
            seq_item_port.item_done();
            `uvm_info(get_full_name(), $sformatf("Completed transaction in %s ...", get_type_name()
                      ), UVM_LOW)
            `uvm_info(get_full_name(), $sformatf("TRANSACTION\n%s", tr.sprint()), UVM_HIGH)
        end
    endtask : run_phase

    //*******************************************************************************
    // Helper Tasks
    //*******************************************************************************
    task tx_driver(requestor_trans_item tr);
        logic [31:0] req_value;
        // Wait for reset to be de-asserted
        if (drv_if.rst == 1) begin
            `uvm_info(get_full_name(), "Waiting for RESET to be de-asserted ...", UVM_LOW)
            drive_rst_values();
            wait (drv_if.rst == 0);
            repeat (5) @(drv_if.requestor_cb);
        end

        req_value = tr.req;
        drv_if.requestor_cb.req <= req_value;

        @(drv_if.requestor_cb);
        // ToDo: Focus here -> Implement the relevant driver transaction code here
        // Wait for grant to stabilize
        //@(drv_if.requestor_cb);
        if (drv_if.requestor_cb.gnt_w != '0) begin
            drv_if.requestor_cb.ack <= 1'b1;  // Assert ack for valid grant
            @(drv_if.requestor_cb);
            drv_if.requestor_cb.ack <= 1'b0;  // Deassert ack after one clock
        end else begin
            drv_if.requestor_cb.ack <= 1'b0;  // Ensure ack is low if no valid grant
        end



    endtask : tx_driver

    // Drive reset values at the interface
    task drive_rst_values();
        // ToDo: Drive reset values at the interface
        drv_if.ack <= 0;
        drv_if.req <= 0;
    endtask : drive_rst_values

endclass : requestor_driver

`endif  // REQUESTOR_DRIVER__SV
