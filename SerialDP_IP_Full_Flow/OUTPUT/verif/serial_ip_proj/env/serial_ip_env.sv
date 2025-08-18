`ifndef SERIAL_IP_ENV__SV
`define SERIAL_IP_ENV__SV

class serial_ip_env extends uvm_env;

  // Components
  serial_ip_scoreboard m_sb;
  serial_agent m_serial_agent;
  clk_rst_agent m_clk_rst_agent;

  // Register with factory
  `uvm_component_utils(serial_ip_env)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "serial_ip_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //******************************************************************************
  // Build Phase
  //******************************************************************************
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_serial_agent = serial_agent::type_id::create("serial_agent", this);
    m_clk_rst_agent = clk_rst_agent::type_id::create("clk_rst_agent", this);
    m_sb = serial_ip_scoreboard::type_id::create("sb", this);
  endfunction : build_phase

  //********************************************************************************
  // Connect Phase
  //********************************************************************************
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor analysis ports to scoreboard analysis exports
    m_serial_agent.m_mon.mon_analysis_port.connect(m_sb.serial_ip_serial_agent_fifo.analysis_export);
    m_clk_rst_agent.m_mon.mon_analysis_port.connect(m_sb.serial_ip_clk_rst_agent_fifo.analysis_export);

  endfunction : connect_phase

  //********************************************************************************
  // Start of Simulation Phase
  //********************************************************************************
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_root::get().print_topology();
    uvm_factory::get().print();
  endfunction : start_of_simulation_phase

endclass : serial_ip_env

`endif  // SERIAL_IP_ENV__SV