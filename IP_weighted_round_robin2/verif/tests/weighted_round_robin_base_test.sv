`ifndef WEIGHTED_ROUND_ROBIN_BASE_TEST__SV
`define WEIGHTED_ROUND_ROBIN_BASE_TEST__SV

class weighted_round_robin_base_test extends uvm_test;

  // Register with factory
  `uvm_component_utils(weighted_round_robin_base_test)

  // Components
  weighted_round_robin_env m_env;
  requestor_agent_cfg m_requestor_agent_cfg; prio_update_agent_cfg m_prio_update_agent_cfg; clk_rst_agent_cfg m_clk_rst_agent_cfg;

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

    m_env = weighted_round_robin_env::type_id::create("m_env", this);

    m_requestor_agent_cfg = requestor_agent_cfg::type_id::create("m_requestor_agent_cfg", this);
    uvm_config_db#(requestor_agent_cfg)::set(this, "*", "requestor_agent_cfg", m_requestor_agent_cfg);
    m_prio_update_agent_cfg = prio_update_agent_cfg::type_id::create("m_prio_update_agent_cfg", this);
    uvm_config_db#(prio_update_agent_cfg)::set(this, "*", "prio_update_agent_cfg", m_prio_update_agent_cfg);
    m_clk_rst_agent_cfg = clk_rst_agent_cfg::type_id::create("m_clk_rst_agent_cfg", this);
    uvm_config_db#(clk_rst_agent_cfg)::set(this, "*", "clk_rst_agent_cfg", m_clk_rst_agent_cfg);
  endfunction : build_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************
  virtual task run_phase(uvm_phase phase);
    requestor_base_sequence m_requestor_base_sequence;
    prio_update_base_sequence m_prio_update_base_sequence;
    clk_rst_base_sequence m_clk_rst_base_sequence;
    m_requestor_base_sequence = requestor_base_sequence::type_id::create("m_requestor_base_sequence");
    m_prio_update_base_sequence = prio_update_base_sequence::type_id::create("m_prio_update_base_sequence");
    m_clk_rst_base_sequence = clk_rst_base_sequence::type_id::create("m_clk_rst_base_sequence");

    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Starting run phase in %s", get_type_name()), UVM_LOW)

    fork
      m_requestor_base_sequence.start(m_env.m_requestor_agent.m_seqr);
      m_prio_update_base_sequence.start(m_env.m_prio_update_agent.m_seqr);
      m_clk_rst_base_sequence.start(m_env.m_clk_rst_agent.m_seqr);
    join

    `uvm_info(get_full_name(), $sformatf("Completed run phase in %s", get_type_name()), UVM_LOW)
    phase.drop_objection(this);
  endtask : run_phase

endclass : weighted_round_robin_base_test

`endif  // WEIGHTED_ROUND_ROBIN_BASE_TEST__SV