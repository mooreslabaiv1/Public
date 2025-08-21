

`ifndef CLK_RST_AGENT_COV__SV
`define CLK_RST_AGENT_COV__SV

class clk_rst_agent_cov extends uvm_component;

  // Register with factory
  `uvm_component_utils(clk_rst_agent_cov)

  // Coverage trigger event
  event cov_event;

  // Transaction item
  clk_rst_trans_item tr;

  // Analysis port
  uvm_analysis_imp #(clk_rst_trans_item, clk_rst_agent_cov) cov_export;

  // Covergroup instance (declare as a variable within the class)
  covergroup cg_trans_h @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup : cg_trans_h

  // Write function implementation
  virtual function void write(clk_rst_trans_item tr);
    this.tr = tr;
    ->cov_event;
  endfunction : write

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_trans_h = new;
    cov_export = new("Coverage Analysis", this);
  endfunction : new

endclass : clk_rst_agent_cov

`endif  // CLK_RST_AGENT_COV__SV