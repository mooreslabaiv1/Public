
`ifndef SERIAL_DRIVER__SV
`define SERIAL_DRIVER__SV

class serial_driver extends uvm_driver #(serial_trans_item);

  // Register with factory
  `uvm_component_utils(serial_driver);

  virtual serial_if drv_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "serial_driver", uvm_component parent = null);
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
    serial_trans_item tr;
    super.run_phase(phase);

    forever begin
      seq_item_port.get_next_item(tr);
      `uvm_info(get_full_name(), $sformatf("Starting transaction in %s ...", get_type_name()), UVM_LOW)
      fork
        tx_driver(tr);
        begin
          @(posedge drv_if.rst);
          `uvm_info(get_full_name(), "RESET DETECTED ...", UVM_LOW)
        end
      join_any
      disable fork;
      seq_item_port.item_done();
      `uvm_info(get_full_name(), $sformatf("Completed transaction in %s ...", get_type_name()), UVM_LOW)
      `uvm_info(get_full_name(), $sformatf("TRANSACTION\n%s", tr.sprint()), UVM_HIGH)
    end
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************
  task tx_driver(serial_trans_item tr);
    // Wait for reset to be de-asserted
    if (drv_if.rst == 1) begin
      `uvm_info(get_full_name(), "Waiting for RESET to be de-asserted ...", UVM_LOW)
      drive_rst_values();
      wait (drv_if.rst == 0);
      // Wait 3 clock cycles after reset de-assertion
      repeat (3) @(drv_if.serial_cb);
    end

    @(drv_if.serial_cb);
    // Drive the interface signal as per transaction
    drv_if.serial_cb.in <= tr.in;
  endtask : tx_driver

  // Drive reset values at the interface
  task drive_rst_values();
    // ToDo: Drive reset values at the interface if needed
  endtask : drive_rst_values

endclass : serial_driver

`endif  // SERIAL_DRIVER__SV