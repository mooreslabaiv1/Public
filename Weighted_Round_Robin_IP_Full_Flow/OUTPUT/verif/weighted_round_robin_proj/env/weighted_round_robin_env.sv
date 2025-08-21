`ifndef WEIGHTED_ROUND_ROBIN_ENV__SV
`define WEIGHTED_ROUND_ROBIN_ENV__SV

class weighted_round_robin_env extends uvm_env;

  // Components
  weighted_round_robin_scoreboard m_sb;
  rr_request_agent m_rr_request_agent;
  rr_grant_monitor_agent m_rr_grant_monitor_agent;
  prio_update_agent m_prio_update_agent;
  clk_rst_agent m_clk_rst_agent;

  // Register with factory
  `uvm_component_utils(weighted_round_robin_env)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "weighted_round_robin_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //******************************************************************************
  // Build Phase
  //******************************************************************************
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_rr_request_agent = rr_request_agent::type_id::create("rr_request_agent", this);
    m_rr_grant_monitor_agent = rr_grant_monitor_agent::type_id::create("rr_grant_monitor_agent", this);
    m_prio_update_agent = prio_update_agent::type_id::create("prio_update_agent", this);
    m_clk_rst_agent = clk_rst_agent::type_id::create("clk_rst_agent", this);
    m_sb = weighted_round_robin_scoreboard::type_id::create("sb", this);
  endfunction : build_phase

  //********************************************************************************
  // Connect Phase
  //********************************************************************************
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor analysis ports to scoreboard analysis exports
    m_rr_request_agent.m_mon.mon_analysis_port.connect(m_sb.weighted_round_robin_rr_request_agent_fifo.analysis_export);
    m_rr_grant_monitor_agent.m_mon.mon_analysis_port.connect(m_sb.weighted_round_robin_rr_grant_monitor_agent_fifo.analysis_export);
    m_prio_update_agent.m_mon.mon_analysis_port.connect(m_sb.weighted_round_robin_prio_update_agent_fifo.analysis_export);
    m_clk_rst_agent.m_mon.mon_analysis_port.connect(m_sb.weighted_round_robin_clk_rst_agent_fifo.analysis_export);

  endfunction : connect_phase

  //********************************************************************************
  // Start of Simulation Phase
  //********************************************************************************
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_root::get().print_topology();
    uvm_factory::get().print();
  endfunction : start_of_simulation_phase

endclass : weighted_round_robin_env

`endif  // WEIGHTED_ROUND_ROBIN_ENV__SV