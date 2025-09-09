`ifndef CLK_RST_MONITOR__SV
`define CLK_RST_MONITOR__SV

class clk_rst_monitor extends uvm_monitor;

  // Register with factory
  `uvm_component_utils(clk_rst_monitor);

  // Analysis port
  uvm_analysis_port #(clk_rst_trans_item) mon_analysis_port;

  // Interface
  virtual clk_rst_if mon_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "clk_rst_monitor", uvm_component parent);
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
      `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");
  endfunction : end_of_elaboration_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      fork
        detect_rst_assert();
        detect_rst_deassert();
      join_any
      disable fork;
    end
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************

  task detect_rst_assert();
    clk_rst_trans_item tr;
    @(posedge mon_if.rst);
    tr = clk_rst_trans_item::type_id::create("tr");
    if (tr == null) begin
      `uvm_error(get_full_name(), "Failed to create transaction item")
      return;
    end
    tr.reset_asserted = 1;
    tr.reset_deasserted = 0;
    mon_analysis_port.write(tr);
    `uvm_info(get_full_name(), "RESET ASSERTED...", UVM_LOW)
  endtask : detect_rst_assert

  task detect_rst_deassert();
    clk_rst_trans_item tr;
    @(negedge mon_if.rst);
    tr = clk_rst_trans_item::type_id::create("tr");
    if (tr == null) begin
      `uvm_error(get_full_name(), "Failed to create transaction item")
      return;
    end
    tr.reset_deasserted = 1;
    tr.reset_asserted = 0;
    mon_analysis_port.write(tr);
    `uvm_info(get_full_name(), "RESET DE-ASSERTED...", UVM_LOW)
  endtask : detect_rst_deassert

endclass : clk_rst_monitor

`endif  // CLK_RST_MONITOR__SV