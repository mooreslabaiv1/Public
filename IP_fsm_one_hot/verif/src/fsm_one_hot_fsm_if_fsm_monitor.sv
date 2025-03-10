`ifndef FSM_ONE_HOT_FSM_MONITOR__SV
`define FSM_ONE_HOT_FSM_MONITOR__SV

import uvm_pkg::*;
`include "fsm_one_hot_fsm_if.sv"

typedef class fsm_one_hot_fsm_agent_base_transaction;

class fsm_one_hot_fsm_monitor extends uvm_monitor;
  event cov_event;
  // Analysis port for scoreboard or coverage collector
  uvm_analysis_port #(fsm_one_hot_fsm_agent_base_transaction) mon_analysis_port;

  // Virtual interface
  typedef virtual fsm_if v_if;
  v_if mon_if;

  covergroup cg_fsm_inputs @(cov_event);
    // <Optional> ToDo: Add required coverpoints, coverbins
  endgroup: cg_fsm_inputs


  `uvm_component_utils_begin(fsm_one_hot_fsm_monitor)
  `uvm_component_utils_end

  // -------------------------
  // new
  // -------------------------
  function new(string name="fsm_one_hot_fsm_monitor", uvm_component parent=null);
    super.new(name, parent);
    mon_analysis_port = new("mon_analysis_port", this);

    cg_fsm_inputs = new;
  endfunction: new

  // -------------------------
  // build_phase
  // -------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  // -------------------------
  // connect_phase
  // -------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Retrieve interface
    if(!uvm_config_db#(v_if)::get(this,"","fsm_agent_fsm_if", mon_if)) begin
      `uvm_fatal("MON_NOIF","No virtual fsm_if provided to monitor");
    end
  endfunction: connect_phase

  // -------------------------
  // run_phase
  // -------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Wait for reset de-assert
    @(negedge mon_if.rst);
    `uvm_info("FSM_MON", "Reset de-asserted; starting monitor", UVM_LOW);

    fork
      monitor_process();
    join
  endtask: run_phase

  // -------------------------
  // monitor_process
  // -------------------------
  protected virtual task monitor_process();
    fsm_one_hot_fsm_agent_base_transaction tr;

    forever begin
      @(posedge mon_if.clk);

      // Create a new transaction
      tr = fsm_one_hot_fsm_agent_base_transaction::type_id::create("mon_tr");
      tr.d             = mon_if.d;
      tr.done_counting = mon_if.done_counting;
      tr.ack           = mon_if.ack;

      // Publish via analysis port
      mon_analysis_port.write(tr);

      `uvm_info("FSM_MON", $sformatf(
        "Observed: d=%0b done_counting=%0b ack=%0b",
        tr.d, tr.done_counting, tr.ack
      ), UVM_LOW);
    end
  endtask: monitor_process

endclass: fsm_one_hot_fsm_monitor

`endif // FSM_ONE_HOT_FSM_MONITOR__SV
