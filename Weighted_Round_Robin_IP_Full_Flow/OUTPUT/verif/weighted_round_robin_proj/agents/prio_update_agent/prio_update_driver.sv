
`ifndef PRIO_UPDATE_DRIVER__SV
`define PRIO_UPDATE_DRIVER__SV

class prio_update_driver extends uvm_driver #(prio_update_trans_item);

  // Register with factory
  `uvm_component_utils(prio_update_driver);

  virtual prio_update_if drv_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "prio_update_driver", uvm_component parent = null);
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
    prio_update_trans_item tr;
    super.run_phase(phase);

    // Drive reset defaults
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
          @(negedge drv_if.rst);
          repeat (2) @(drv_if.prio_update_cb);
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
  task tx_driver(prio_update_trans_item tr);
    // Wait for reset to be de-asserted
    if (drv_if.rst == 1) begin
      `uvm_info(get_full_name(), "Waiting for RESET to be de-asserted ...", UVM_LOW)
      drive_rst_values();
      wait (drv_if.rst == 0);
      repeat (2) @(drv_if.prio_update_cb);
    end

    @(drv_if.prio_update_cb);
    drv_if.prio_update_cb.prio     <= tr.prio;
    drv_if.prio_update_cb.prio_id  <= tr.prio_id;
    drv_if.prio_update_cb.prio_upt <= tr.prio_upt;
  endtask : tx_driver

  // Drive reset values at the interface
  task drive_rst_values();
    @(drv_if.prio_update_cb);
    drv_if.prio_update_cb.prio     <= '0;
    drv_if.prio_update_cb.prio_id  <= '0;
    drv_if.prio_update_cb.prio_upt <= 1'b0;
  endtask : drive_rst_values

endclass : prio_update_driver

`endif  // PRIO_UPDATE_DRIVER__SV