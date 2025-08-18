
`ifndef SERIAL_IP_BASE_TEST__SV
`define SERIAL_IP_BASE_TEST__SV

class serial_ip_base_test extends uvm_test;

  // Register with factory
  `uvm_component_utils(serial_ip_base_test)

  // Components
  serial_ip_env       m_env;
  serial_agent_cfg    m_serial_agent_cfg;
  clk_rst_agent_cfg   m_clk_rst_agent_cfg;

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
    super.build_phase(phase);

    uvm_top.set_timeout(30000, 1);

    m_env = serial_ip_env::type_id::create("m_env", this);

    m_serial_agent_cfg = serial_agent_cfg::type_id::create("m_serial_agent_cfg", this);
    uvm_config_db#(serial_agent_cfg)::set(this, "*", "serial_agent_cfg", m_serial_agent_cfg);

    m_clk_rst_agent_cfg = clk_rst_agent_cfg::type_id::create("m_clk_rst_agent_cfg", this);
    uvm_config_db#(clk_rst_agent_cfg)::set(this, "*", "clk_rst_agent_cfg", m_clk_rst_agent_cfg);
  endfunction : build_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************
  virtual task run_phase(uvm_phase phase);
    serial_base_sequence    m_serial_base_sequence;
    clk_rst_base_sequence   m_clk_rst_base_sequence;

    // Declarations at start of task
    phase.raise_objection(this);

    m_serial_base_sequence  = serial_base_sequence::type_id::create("m_serial_base_sequence");
    m_clk_rst_base_sequence = clk_rst_base_sequence::type_id::create("m_clk_rst_base_sequence");

    `uvm_info(get_full_name(), $sformatf("Starting run phase in %s", get_type_name()), UVM_LOW)

    // Run default sequences
    fork
      m_serial_base_sequence.start(m_env.m_serial_agent.m_seqr);
      m_clk_rst_base_sequence.start(m_env.m_clk_rst_agent.m_seqr);
    join

    `uvm_info(get_full_name(), $sformatf("Completed run phase in %s", get_type_name()), UVM_LOW)

    phase.drop_objection(this);
  endtask : run_phase

endclass : serial_ip_base_test

`endif  // SERIAL_IP_BASE_TEST__SV