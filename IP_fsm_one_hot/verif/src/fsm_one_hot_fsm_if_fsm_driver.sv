`ifndef FSM_ONE_HOT_FSM_DRIVER__SV
`define FSM_ONE_HOT_FSM_DRIVER__SV

import uvm_pkg::*;
`include "fsm_one_hot_fsm_if.sv"

typedef class fsm_one_hot_fsm_agent_base_transaction;

class fsm_one_hot_fsm_driver extends uvm_driver #(fsm_one_hot_fsm_agent_base_transaction);

  // Virtual interface from config_db
  typedef virtual fsm_if v_if;
  v_if drv_if;

  `uvm_component_utils_begin(fsm_one_hot_fsm_driver)
  `uvm_component_utils_end

  // -------------------------
  // new
  // -------------------------
  function new(string name="fsm_one_hot_fsm_driver", uvm_component parent=null);
    super.new(name, parent);
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

    // Retrieve the virtual interface
    if (!uvm_config_db#(v_if)::get(this, "", "fsm_agent_fsm_if", drv_if)) begin
      `uvm_fatal("NO_VIF","No virtual interface provided to driver");
    end
  endfunction: connect_phase

  // -------------------------
  // end_of_elaboration_phase
  // -------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (drv_if == null) begin
      `uvm_fatal("NULL_IF", "Driver's interface handle is null");
    end
  endfunction: end_of_elaboration_phase

  // -------------------------
  // reset_phase
  // -------------------------
  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    // Initialize signals to 0 during reset if desired
    drv_if.d             <= 1'b0;
    drv_if.done_counting <= 1'b0;
    drv_if.ack           <= 1'b0;
  endtask: reset_phase

  // -------------------------
  // run_phase
  // -------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Wait for reset de-assert
    @(negedge drv_if.rst);
    `uvm_info("FSM_DRV","Reset de-asserted; starting driver",UVM_LOW);

    fork
      tx_driver();
    join
  endtask: run_phase

  // -------------------------
  // tx_driver
  // -------------------------
  protected virtual task tx_driver();
    fsm_one_hot_fsm_agent_base_transaction tr;

    forever begin
      // Fetch next transaction from sequencer
      seq_item_port.get_next_item(tr);

      // Wait one clock edge to apply signals
      @(posedge drv_if.clk);

      // Drive all signals at once
      drv_if.d             <= tr.d;
      drv_if.done_counting <= tr.done_counting;
      drv_if.ack           <= tr.ack;

      `uvm_info("FSM_DRV", $sformatf(
        "Driving: d=%0b done_counting=%0b ack=%0b",
        tr.d, tr.done_counting, tr.ack
      ), UVM_LOW);

      // Transaction done
      seq_item_port.item_done();
    end
  endtask: tx_driver

endclass: fsm_one_hot_fsm_driver

`endif // FSM_ONE_HOT_FSM_DRIVER__SV
