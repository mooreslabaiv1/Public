

`ifndef RR_REQUEST_DRIVER__SV
`define RR_REQUEST_DRIVER__SV

class rr_request_driver extends uvm_driver #(rr_request_trans_item);

  // Register with factory
  `uvm_component_utils(rr_request_driver);

  virtual rr_request_if drv_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "rr_request_driver", uvm_component parent = null);
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
    rr_request_trans_item tr;
    super.run_phase(phase);

    // Drive reset values initially
    drive_rst_values();

    forever begin
      tr = null;
      seq_item_port.get_next_item(tr);
      `uvm_info(get_full_name(), $sformatf("Starting transaction in %s ...", get_type_name()), UVM_LOW)
      fork
        tx_driver(tr);
        begin
          @(posedge drv_if.rst);
          `uvm_info(get_full_name(), "RESET DETECTED ...", UVM_LOW)
          drive_rst_values();
          // Wait for reset deassertion before continuing
          @(negedge drv_if.rst);
          repeat (2) @(drv_if.rr_request_cb);
        end
      join_any
      disable fork;
      seq_item_port.item_done();
      `uvm_info(get_full_name(), $sformatf("Completed transaction in %s ...", get_type_name()), UVM_LOW)
      `uvm_info(get_full_name(), $sformatf("TRANSACTION\\n%s", tr.sprint()), UVM_HIGH)
    end
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************
  task tx_driver(rr_request_trans_item tr);
    // Wait for reset to be de-asserted
    if (drv_if.rst == 1) begin
      `uvm_info(get_full_name(), "Waiting for RESET to be de-asserted ...", UVM_LOW)
      drive_rst_values();
      wait (drv_if.rst == 0);
      repeat (2) @(drv_if.rr_request_cb);
    end

    // Drive this cycle using clocking block
    @(drv_if.rr_request_cb);
    drv_if.rr_request_cb.req <= tr.req;
    drv_if.rr_request_cb.ack <= tr.ack;
  endtask : tx_driver

  // Drive reset values at the interface
  task drive_rst_values();
    // Drive through clocking block for proper timing
    @(drv_if.rr_request_cb);
    drv_if.rr_request_cb.req <= '0;
    drv_if.rr_request_cb.ack <= 1'b0;
  endtask : drive_rst_values

endclass : rr_request_driver

`endif  // RR_REQUEST_DRIVER__SV