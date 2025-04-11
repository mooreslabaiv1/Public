`ifndef WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST__SV
`define WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST__SV

class weighted_round_robin_basic_functionality_test extends weighted_round_robin_base_test;

    // Register with factory
    `uvm_component_utils(weighted_round_robin_basic_functionality_test)

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
        requestor_basic_functionality_sequence m_requestor_basic_functionality_sequence;
        prio_update_basic_functionality_sequence m_prio_update_basic_functionality_sequence;
        clk_rst_base_sequence m_clk_rst_base_sequence;
        m_requestor_basic_functionality_sequence =
            requestor_basic_functionality_sequence::type_id::create(
            "m_requestor_basic_functionality_sequence");
        m_prio_update_basic_functionality_sequence =
            prio_update_basic_functionality_sequence::type_id::create(
            "m_prio_update_basic_functionality_sequence");
        m_clk_rst_base_sequence = clk_rst_base_sequence::type_id::create("m_clk_rst_base_sequence");

        phase.raise_objection(this);
        `uvm_info(get_full_name(), $sformatf("Starting run phase in %s", get_type_name()), UVM_LOW)

        fork
            m_clk_rst_base_sequence.start(m_env.m_clk_rst_agent.m_seqr);
            m_requestor_basic_functionality_sequence.start(m_env.m_requestor_agent.m_seqr);
            m_prio_update_basic_functionality_sequence.start(m_env.m_prio_update_agent.m_seqr);
        join

        `uvm_info(get_full_name(), $sformatf("Completed run phase in %s", get_type_name()), UVM_LOW)
        phase.drop_objection(this);
    endtask : run_phase

endclass : weighted_round_robin_basic_functionality_test

`endif  // WEIGHTED_ROUND_ROBIN_BASIC_FUNCTIONALITY_TEST__SV
