
`ifndef WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV
`define WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV

class weighted_round_robin_scoreboard extends uvm_scoreboard;

    // TLM Fifo (analysis port)
    uvm_tlm_analysis_fifo #(requestor_trans_item) weighted_round_robin_requestor_agent_fifo;
    uvm_tlm_analysis_fifo #(prio_update_trans_item) weighted_round_robin_prio_update_agent_fifo;
    uvm_tlm_analysis_fifo #(clk_rst_trans_item) weighted_round_robin_clk_rst_agent_fifo;

    // Register with factory
    `uvm_component_utils(weighted_round_robin_scoreboard)

    // Declare a object to the reference model class
    weighted_round_robin_ref_model #(
        .N(32),
        .PRIORITY_W(4)
    ) ref_model;

    //******************************************************************************
    // Constructor
    //******************************************************************************
    function new(string name = "weighted_round_robin_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //*****************************************************************************
    // Build Phase
    //*****************************************************************************
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        weighted_round_robin_requestor_agent_fifo =
            new("weighted_round_robin_requestor_agent_fifo", this);
        weighted_round_robin_prio_update_agent_fifo =
            new("weighted_round_robin_prio_update_agent_fifo", this);
        weighted_round_robin_clk_rst_agent_fifo =
            new("weighted_round_robin_clk_rst_agent_fifo", this);

        // Create a instance using the create function for the reference model object
        // Example: ref_model = <reference model class>::type_id::create("ref_model", this);
        ref_model = weighted_round_robin_ref_model#(
            .N(32),
            .PRIORITY_W(4)
        )::type_id::create(
            "ref_model", this
        );

    endfunction : build_phase

    //******************************************************************************
    // Connect Phase
    //******************************************************************************
    function void connect_phase(uvm_phase phase);
    endfunction : connect_phase

    //******************************************************************************
    // Run Phase
    //******************************************************************************  
    task run_phase(uvm_phase phase);
        fork
            process_requestor_agent_fifo();
            process_prio_update_agent_fifo();
            process_clk_rst_agent_fifo();

        join_none
    endtask : run_phase

    //*******************************************************************************
    // Helper Tasks
    //*******************************************************************************  

    task process_requestor_agent_fifo();
        requestor_trans_item        tr;
        bit                  [31:0] request_bits;
        bit                         ack_val;
        int                         dut_grant_id;
        int                         expected_grant_id;
        forever begin
            weighted_round_robin_requestor_agent_fifo.get(tr);
            `uvm_info(get_full_name(), $sformatf("RECEIVED TRANSACTION\n%s", tr.sprint()), UVM_LOW)
            // Implement checker here

            // Assign local variables
            request_bits      = tr.req;
            ack_val           = tr.ack;
            dut_grant_id      = tr.gnt_id;

            // Reference model calculates expected grant
            expected_grant_id = ref_model.calc_grant(request_bits, ack_val);

            // Compare
            if (expected_grant_id != dut_grant_id) begin
                `uvm_error(
                    "SBD",
                    $sformatf(
                        "WWR mismatch: Req=0x%8h, ack=%0b, expected_grant_id=%0d, dut_grant_id=%0d",
                        request_bits, ack_val, expected_grant_id, dut_grant_id))
            end else begin
                `uvm_info(
                    "SBD", $sformatf(
                    "WWR match: Req=0x%8h, ack=%0b => ID=%0d", request_bits, ack_val, dut_grant_id),
                    UVM_LOW)
            end
        end
    endtask : process_requestor_agent_fifo

    task process_prio_update_agent_fifo();
        prio_update_trans_item tr;
        forever begin
            weighted_round_robin_prio_update_agent_fifo.get(tr);
            `uvm_info(get_full_name(), $sformatf("RECEIVED TRANSACTION\n%s", tr.sprint()), UVM_LOW)
            // Implement checker here
            if (tr.prio_upt) begin
                ref_model.update_priority(tr.prio, tr.prio_id);
            end
        end
    endtask : process_prio_update_agent_fifo

    task process_clk_rst_agent_fifo();
        clk_rst_trans_item tr;
        forever begin
            weighted_round_robin_clk_rst_agent_fifo.get(tr);
            `uvm_info(get_full_name(), $sformatf("RESET TRANSACTION\n%s", tr.sprint()), UVM_LOW)

            // Reset FIFOs
            if (tr.reset_asserted || tr.reset_deasserted) begin
                weighted_round_robin_requestor_agent_fifo.flush();
                weighted_round_robin_prio_update_agent_fifo.flush();
                weighted_round_robin_clk_rst_agent_fifo.flush();
                ref_model.reset();
            end
        end
    endtask : process_clk_rst_agent_fifo


endclass : weighted_round_robin_scoreboard
`endif  // WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV
