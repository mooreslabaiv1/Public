`ifndef WEIGHTED_ROUND_ROBIN_SBD__SV
`define WEIGHTED_ROUND_ROBIN_SBD__SV

`uvm_analysis_imp_decl(_wrr_req)

class weighted_round_robin_sbd extends uvm_scoreboard;

  // ----------------------------------------------------------
  // TLM FIFOs that receive monitor transactions
  // ----------------------------------------------------------
  uvm_tlm_analysis_fifo #(weighted_round_robin_requestor_agent_base_transaction) 
      requestor_fifo;

  uvm_tlm_analysis_fifo #(weighted_round_robin_priority_update_agent_base_transaction)
      priority_update_fifo;

  // ----------------------------------------------------------
  // Reference Model instance
  // ----------------------------------------------------------
  weighted_round_robin_ref_model #(
    .N(32),
    .PRIORITY_W(4)
  ) ref_model;

  // UVM factory registration
   `uvm_component_utils(weighted_round_robin_sbd)

  // ----------------------------------------------------------
  // Constructor
  // ----------------------------------------------------------
  function new(string name="weighted_round_robin_sbd", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------
  // build_phase
  // ----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    requestor_fifo       = new("requestor_fifo",       this);
    priority_update_fifo = new("priority_update_fifo", this);

    ref_model = weighted_round_robin_ref_model #(
      .N(32),
      .PRIORITY_W(4)
    )::type_id::create("ref_model", this);
  endfunction

  // ----------------------------------------------------------
  // connect_phase
  // ----------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  // ----------------------------------------------------------
  // main_phase
  // ----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    // -------------------------------
    // DECLARE ALL VARIABLES UP FRONT
    // -------------------------------
    weighted_round_robin_requestor_agent_base_transaction      req_tr;
    weighted_round_robin_priority_update_agent_base_transaction prio_tr;
    bit [31:0] request_bits;
    bit         ack_val;
    int         dut_grant_id;
    int         expected_grant_id;
    super.run_phase(phase);

    `uvm_info(get_type_name(), "Scoreboard run_phase started.", UVM_LOW)

    forever begin
      // 1) Non-blocking check for priority updates
      if (priority_update_fifo.try_get(prio_tr)) begin
        if (prio_tr.prio_upt) begin
          ref_model.update_priority(prio_tr.prio, prio_tr.prio_id);
          `uvm_info("SBD", $sformatf("RefModel: Priority updated. ID=%0d => p=0x%0h",
                     prio_tr.prio_id, prio_tr.prio), UVM_LOW)
        end
      end
      // 2) Block on the next request transaction
      requestor_fifo.get(req_tr);

      // Assign local variables
      request_bits = req_tr.req;
      ack_val      = req_tr.ack;
      dut_grant_id = req_tr.gnt_id;

      // 3) Reference model calculates expected grant
      expected_grant_id = ref_model.calc_grant(request_bits, ack_val);

      // 4) Compare
      if (expected_grant_id != dut_grant_id) begin
        `uvm_error("SBD",
          $sformatf("WWR mismatch: Req=0x%8h, ack=%0b, expected_grant_id=%0d, dut_grant_id=%0d",
                    request_bits, ack_val, expected_grant_id, dut_grant_id))
      end
      else begin
        `uvm_info("SBD",
          $sformatf("WWR match: Req=0x%8h, ack=%0b => ID=%0d", 
                    request_bits, ack_val, dut_grant_id), UVM_LOW)
      end
    end
  endtask : run_phase

endclass : weighted_round_robin_sbd

`endif // WEIGHTED_ROUND_ROBIN_SBD__SV
