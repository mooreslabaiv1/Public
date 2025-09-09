`ifndef CLK_RST_DRIVER__SV
`define CLK_RST_DRIVER__SV

class clk_rst_driver extends uvm_driver #(clk_rst_trans_item);

  // Register with factory
  `uvm_component_utils(clk_rst_driver);

  // Interface
  virtual clk_rst_if drv_if;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "clk_rst_driver", uvm_component parent = null);
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

    // Initialize clk driver
    drv_if.clk = 1'b0;   
    drv_if.clk_div = 1'b0;
    drv_if.rst = 1'b1;

    forever begin
      clk_rst_trans_item tr;
      seq_item_port.get_next_item(tr);
      `uvm_info(get_full_name(), $sformatf("Starting transaction in %s ...", get_type_name()), UVM_LOW)
      tx_driver(tr);
      seq_item_port.item_done();
      `uvm_info(get_full_name(), $sformatf("Completed transaction in %s ...", get_type_name()), UVM_LOW)
      `uvm_info(get_full_name(), $sformatf("TRANSACTION\\n %s", tr.sprint()), UVM_LOW)
    end
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************  

  // TX Driver
  task tx_driver(clk_rst_trans_item tr);
    case (tr.op_type)
      RST_APPLY:   apply_reset(tr);
      CLK_SET:     set_clk(tr);
      WAIT_CYCLES: wait_cycles(tr);
      default:     `uvm_error("CLK_RST_DRV", "No such operation")
    endcase
  endtask : tx_driver

  //Apply reset
  task apply_reset(clk_rst_trans_item tr);
    int rst_shift;
    rst_shift = tr.rst_shift;
    if (rst_shift) #(rst_shift);
    drv_if.rst = 1'b1;
    repeat (tr.rst_wait_cycles) @(posedge drv_if.clk);
    if (rst_shift) #(rst_shift);
    drv_if.rst = 1'b0;
  endtask : apply_reset

  //Set Clocks
  task set_clk(clk_rst_trans_item tr);
    fork
      begin
        int half_period = tr.period / 2;
        forever drv_if.clk = #(half_period) ~drv_if.clk;
      end
      begin
        if (tr.div_clk_shift) #(tr.div_clk_shift);
        forever drv_if.clk_div = #(tr.period * tr.divider / 2) ~drv_if.clk_div;
      end
    join_none
  endtask : set_clk

  //Wait cycles
  task wait_cycles(clk_rst_trans_item tr);
    repeat (tr.wait_clk_cycles) @(posedge drv_if.clk);
  endtask : wait_cycles

endclass : clk_rst_driver
`endif  // CLK_RST_DRIVER__SV