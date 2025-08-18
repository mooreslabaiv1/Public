`ifndef CLK_RST_AGENT__SV
`define CLK_RST_AGENT__SV

class clk_rst_agent extends uvm_agent;

  // Register with factory
  `uvm_component_utils(clk_rst_agent)

  // Interface
  typedef virtual clk_rst_if v_if;
  v_if m_vif;

  // Components
  clk_rst_seqr      m_seqr;
  clk_rst_driver    m_drv;
  clk_rst_monitor   m_mon;
  clk_rst_agent_cfg m_cfg;
  clk_rst_agent_cov m_cov;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "clk_rst_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //******************************************************************************
  // Build Phase
  //******************************************************************************
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_mon = clk_rst_monitor::type_id::create("m_mon", this);

    if (!uvm_config_db#(clk_rst_agent_cfg)::get(this, "*", "clk_rst_agent_cfg", m_cfg)) begin
      `uvm_warning("NOCFG", "No agent_cfg found; using defaults")
      m_cfg = clk_rst_agent_cfg::type_id::create("m_cfg", this);
    end

    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_seqr = clk_rst_seqr::type_id::create("m_seqr", this);
      m_drv  = clk_rst_driver::type_id::create("m_drv", this);
    end

    if (m_cfg.has_functional_coverage) begin
      m_cov = clk_rst_agent_cov::type_id::create("m_cov", this);
    end

    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "clk_rst_if", m_vif)) begin
      `uvm_fatal("NOVIF", "No virtual interface specified for this agent instance")
    end
    m_drv.drv_if = m_vif;
    m_mon.mon_if = m_vif;

  endfunction : build_phase

  //********************************************************************************
  // Connect Phase
  //********************************************************************************
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
    end
    
    if (m_cfg.has_functional_coverage) begin
      m_mon.mon_analysis_port.connect(m_cov.cov_export);
    end

  endfunction : connect_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************   
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase

endclass : clk_rst_agent

`endif  // CLK_RST_AGENT__SV