
`ifndef SERIAL_MONITOR__SV
`define SERIAL_MONITOR__SV

class serial_monitor extends uvm_monitor;

  // Register with factory
  `uvm_component_utils(serial_monitor);

  // Analysis port
  uvm_analysis_port #(serial_trans_item) mon_analysis_port;

  // Interface
  virtual serial_if mon_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "serial_monitor", uvm_component parent);
    super.new(name, parent);
    mon_analysis_port = new("mon_analysis_port", this);
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
    if (mon_if == null)
      `uvm_fatal("NO_CONN", "Virtual interface not connected");
  endfunction : end_of_elaboration_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      fork
        tx_monitor();
        @(posedge mon_if.rst)
          `uvm_info(get_full_name(), "RESET DETECTED ...", UVM_LOW)
      join_any
      disable fork;
    end
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************
  task tx_monitor();
    serial_trans_item tr;
    if (mon_if.rst == 1) begin
      `uvm_info(get_full_name(), "Waiting for RESET de-assertion...", UVM_LOW)
      wait (mon_if.rst == 0);
    end
    tr = serial_trans_item::type_id::create("tr");

    @(posedge mon_if.clk);
    tr.in       = mon_if.in;
    tr.out_byte = mon_if.out_byte;
    tr.done     = mon_if.done;

    mon_analysis_port.write(tr);
    `uvm_info(get_full_name(), $sformatf("TRANSACTION\n%s", tr.sprint()), UVM_HIGH)
  endtask : tx_monitor

endclass : serial_monitor

`endif  // SERIAL_MONITOR__SV