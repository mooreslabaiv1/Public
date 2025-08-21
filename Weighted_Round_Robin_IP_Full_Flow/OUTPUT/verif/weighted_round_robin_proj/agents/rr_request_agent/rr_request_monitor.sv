
`ifndef RR_REQUEST_MONITOR__SV
`define RR_REQUEST_MONITOR__SV

class rr_request_monitor extends uvm_monitor;

  // Register with factory
  `uvm_component_utils(rr_request_monitor);

  // Analysis port
  uvm_analysis_port #(rr_request_trans_item) mon_analysis_port;

  // Interface
  virtual rr_request_if mon_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "rr_request_monitor", uvm_component parent);
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
    rr_request_trans_item tr;
    if (mon_if.rst == 1) begin
      `uvm_info(get_full_name(), "Waiting for RESET de-assertion...", UVM_LOW)
      wait (mon_if.rst == 0);
    end
    tr = rr_request_trans_item::type_id::create("tr");
    
    @(mon_if.rr_request_cb);
    // Sample interface signals
    tr.req = mon_if.req;
    tr.ack = mon_if.ack;

    mon_analysis_port.write(tr);
    `uvm_info(get_full_name(), $sformatf("TRANSACTION\\n%s", tr.sprint()), UVM_HIGH)
  endtask : tx_monitor

endclass : rr_request_monitor

`endif  // RR_REQUEST_MONITOR__SV