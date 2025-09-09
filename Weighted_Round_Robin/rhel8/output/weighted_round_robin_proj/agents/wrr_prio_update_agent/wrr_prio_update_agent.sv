`ifndef WRR_PRIO_UPDATE_AGENT__SV
`define WRR_PRIO_UPDATE_AGENT__SV

class wrr_prio_update_agent extends uvm_agent;

  // Register with factory
  `uvm_component_utils(wrr_prio_update_agent)

  // Interface
  typedef virtual wrr_prio_update_if v_if;
  v_if m_vif;

  // Components
  wrr_prio_update_seqr      m_seqr;
  wrr_prio_update_driver    m_drv;
  wrr_prio_update_monitor   m_mon;
  wrr_prio_update_agent_cfg m_cfg;
  wrr_prio_update_agent_cov m_cov;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "wrr_prio_update_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //******************************************************************************
  // Build Phase
  //******************************************************************************
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_mon = wrr_prio_update_monitor::type_id::create("m_mon", this);

    if (!uvm_config_db#(wrr_prio_update_agent_cfg)::get(this, "*", "wrr_prio_update_agent_cfg", m_cfg)) begin
      `uvm_warning("NOCFG", "No configuration object set by the base_test - Using default");
      m_cfg = wrr_prio_update_agent_cfg::type_id::create("m_cfg", this);
    end

    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_seqr = wrr_prio_update_seqr::type_id::create("m_seqr", this);
      m_drv  = wrr_prio_update_driver::type_id::create("m_drv", this);
    end

    if (m_cfg.has_functional_coverage) begin
      m_cov = wrr_prio_update_agent_cov::type_id::create("m_cov", this);
    end

    if (!uvm_config_db#(v_if)::get(this, "", "wrr_prio_update_if", m_vif)) begin
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

endclass : wrr_prio_update_agent

`endif  // WRR_PRIO_UPDATE_AGENT__SV