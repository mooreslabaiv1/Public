

`ifndef WEIGHTED_ROUND_ROBIN_BASE_TEST__SV
`define WEIGHTED_ROUND_ROBIN_BASE_TEST__SV

class weighted_round_robin_base_test extends uvm_test;

  // Register with factory
  `uvm_component_utils(weighted_round_robin_base_test)

  // Components
  weighted_round_robin_env m_env;
  rr_request_agent_cfg m_rr_request_agent_cfg; 
  rr_grant_monitor_agent_cfg m_rr_grant_monitor_agent_cfg; 
  prio_update_agent_cfg m_prio_update_agent_cfg; 
  clk_rst_agent_cfg m_clk_rst_agent_cfg;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //******************************************************************************
  // Build Phase
  //******************************************************************************
  virtual function void build_phase(uvm_phase phase);
    string test_name;
    super.build_phase(phase);

    // Keep a reasonable simulation timeout (increased to avoid premature PH_TIMEOUT during long tests)
    uvm_top.set_timeout(1_000_000, 1);

    // Create environment
    m_env = weighted_round_robin_env::type_id::create("m_env", this);

    // Configure all agents (keep active; scoreboard connects to monitors)
    m_rr_request_agent_cfg = rr_request_agent_cfg::type_id::create("m_rr_request_agent_cfg", this);
    uvm_config_db#(rr_request_agent_cfg)::set(this, "*", "rr_request_agent_cfg", m_rr_request_agent_cfg);

    m_rr_grant_monitor_agent_cfg = rr_grant_monitor_agent_cfg::type_id::create("m_rr_grant_monitor_agent_cfg", this);
    uvm_config_db#(rr_grant_monitor_agent_cfg)::set(this, "*", "rr_grant_monitor_agent_cfg", m_rr_grant_monitor_agent_cfg);

    m_prio_update_agent_cfg = prio_update_agent_cfg::type_id::create("m_prio_update_agent_cfg", this);
    uvm_config_db#(prio_update_agent_cfg)::set(this, "*", "prio_update_agent_cfg", m_prio_update_agent_cfg);

    m_clk_rst_agent_cfg = clk_rst_agent_cfg::type_id::create("m_clk_rst_agent_cfg", this);
    uvm_config_db#(clk_rst_agent_cfg)::set(this, "*", "clk_rst_agent_cfg", m_clk_rst_agent_cfg);
  endfunction : build_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************
  virtual task run_phase(uvm_phase phase);
    clk_rst_base_sequence m_clk_rst_base_sequence;
    m_clk_rst_base_sequence = clk_rst_base_sequence::type_id::create("m_clk_rst_base_sequence");

    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Starting run phase in %s", get_type_name()), UVM_LOW)

    // For base test, bring clocks up and apply a clean reset.
    // Stimulus sequences for request/prio can be layered in derived tests.
    m_clk_rst_base_sequence.start(m_env.m_clk_rst_agent.m_seqr);

    `uvm_info(get_full_name(), $sformatf("Completed run phase in %s", get_type_name()), UVM_LOW)
    phase.drop_objection(this);
  endtask : run_phase

endclass : weighted_round_robin_base_test

`endif  // WEIGHTED_ROUND_ROBIN_BASE_TEST__SV