`ifndef WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV
`define WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV

class weighted_round_robin_scoreboard extends uvm_scoreboard;

  // TLM Fifo (analysis port)
  uvm_tlm_analysis_fifo #(rr_trans_item) weighted_round_robin_rr_agent_fifo;
  uvm_tlm_analysis_fifo #(prio_update_trans_item) weighted_round_robin_prio_update_agent_fifo;
  uvm_tlm_analysis_fifo #(clk_rst_trans_item) weighted_round_robin_clk_rst_agent_fifo;

  // Register with factory
  `uvm_component_utils(weighted_round_robin_scoreboard)

  // Declare a object to the reference model class

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

    weighted_round_robin_rr_agent_fifo = new("weighted_round_robin_rr_agent_fifo", this);
    weighted_round_robin_prio_update_agent_fifo = new("weighted_round_robin_prio_update_agent_fifo", this);
    weighted_round_robin_clk_rst_agent_fifo = new("weighted_round_robin_clk_rst_agent_fifo", this);

    // Create a instance using the create function for the reference model object
    // Example: ref_model = <reference model class>::type_id::create("ref_model", this);

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
      process_rr_agent_fifo();
      process_prio_update_agent_fifo();
      process_clk_rst_agent_fifo();

    join_none
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************  
task process_rr_agent_fifo();
  rr_trans_item tr;
  forever begin
    weighted_round_robin_rr_agent_fifo.get(tr);
    `uvm_info(get_full_name(), $sformatf("RECEIVED TRANSACTION\\n%s", tr.sprint()), UVM_HIGH)
    // Implement checker here
  end
endtask : process_rr_agent_fifo
task process_prio_update_agent_fifo();
  prio_update_trans_item tr;
  forever begin
    weighted_round_robin_prio_update_agent_fifo.get(tr);
    `uvm_info(get_full_name(), $sformatf("RECEIVED TRANSACTION\\n%s", tr.sprint()), UVM_HIGH)
    // Implement checker here
  end
endtask : process_prio_update_agent_fifo
task process_clk_rst_agent_fifo();
    clk_rst_trans_item tr;
    forever begin
      weighted_round_robin_clk_rst_agent_fifo.get(tr);
      `uvm_info(get_full_name(), $sformatf("RESET TRANSACTION\\n%s", tr.sprint()), UVM_LOW)

      // Reset FIFOs
      if (tr.reset_asserted || tr.reset_deasserted) begin
        weighted_round_robin_rr_agent_fifo.flush();
weighted_round_robin_prio_update_agent_fifo.flush();
weighted_round_robin_clk_rst_agent_fifo.flush();
      end
    end
  endtask : process_clk_rst_agent_fifo


endclass : weighted_round_robin_scoreboard
`endif  // WEIGHTED_ROUND_ROBIN_SCOREBOARD__SV