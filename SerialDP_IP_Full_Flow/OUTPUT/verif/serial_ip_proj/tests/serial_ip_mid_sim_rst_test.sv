`ifndef SERIAL_IP_MID_SIM_RST_TEST__SV
`define SERIAL_IP_MID_SIM_RST_TEST__SV

class serial_ip_mid_sim_rst_test extends serial_ip_base_test;

  // Register with factory
  `uvm_component_utils(serial_ip_mid_sim_rst_test)

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
  endfunction : build_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************   
  virtual task run_phase(uvm_phase phase);
    serial_base_sequence m_serial_base_sequence;
    clk_rst_mid_sim_rst_sequence m_clk_rst_mid_sim_rst_sequence;
    m_serial_base_sequence = serial_base_sequence::type_id::create("m_serial_base_sequence");
    m_clk_rst_mid_sim_rst_sequence = clk_rst_mid_sim_rst_sequence::type_id::create("m_clk_rst_mid_sim_rst_sequence");

    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Starting run phase in %s", get_type_name()), UVM_LOW)

    fork
      m_clk_rst_mid_sim_rst_sequence.start(m_env.m_clk_rst_agent.m_seqr);
      m_serial_base_sequence.start(m_env.m_serial_agent.m_seqr);
    join

    `uvm_info(get_full_name(), $sformatf("Completed run phase in %s", get_type_name()), UVM_LOW)
    phase.drop_objection(this);
  endtask : run_phase

endclass : serial_ip_mid_sim_rst_test

`endif  // SERIAL_IP_MID_SIM_RST_TEST__SV