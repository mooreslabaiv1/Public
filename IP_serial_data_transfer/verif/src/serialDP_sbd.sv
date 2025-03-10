`ifndef SERIALDP_SBD__SV
`define SERIALDP_SBD__SV

import uvm_pkg::*;
`include "serialDP_serial_agent_transaction.sv"
`include "serialDP_ref_model.sv"

class serialDP_sbd extends uvm_scoreboard;

   // TLM FIFO that receives the final transaction from the monitor
   uvm_tlm_analysis_fifo #(serialDP_serial_agent_base_transaction) serialDP_serial_agent_fifo;

   // The reference model
   serialDP_ref_model ref_model;

   `uvm_component_utils(serialDP_sbd)

   //------------------------------------------------------
   // Constructor
   //------------------------------------------------------
   function new(string name="serialDP_sbd", uvm_component parent=null);
      super.new(name,parent);
   endfunction: new

   //------------------------------------------------------
   // build_phase
   //------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      serialDP_serial_agent_fifo = new("serialDP_serial_agent_fifo", this);

      // Create the reference model
      ref_model = serialDP_ref_model::type_id::create("ref_model", this);
   endfunction: build_phase

   //------------------------------------------------------
   // run_phase - scoreboard loop
   //------------------------------------------------------
   virtual task run_phase(uvm_phase phase);
      serialDP_serial_agent_base_transaction tr;
      logic [7:0] ref_data;
      bit ref_par;
      bit dut_par;
      bit ref_stop;
      bit ref_done_val;
      bit scoreboard_passed;
      super.run_phase(phase);

      forever begin
         // Get next transaction from the FIFO
         serialDP_serial_agent_fifo.get(tr);

         // Provide the 10-bit frame + stop bit to the reference model
         ref_model.set_frame(tr.full_frame, tr.stop_bit);

         // Now do a field-by-field comparison
         scoreboard_passed = 1;

         // 1) Compare start bit
         if (ref_model.get_start_bit() !== tr.full_frame[0]) begin
            scoreboard_passed = 0;
            `uvm_error("SBD", $sformatf(
               "Mismatch in start bit: ref=%b, dut=%b",
               ref_model.get_start_bit(), tr.full_frame[0]))
         end

         // 2) Compare data bits
         ref_data = ref_model.get_data_bits();
         if (ref_data !== tr.out_byte) begin
            scoreboard_passed = 0;
            `uvm_error("SBD", $sformatf(
               "Mismatch in data bits: ref=0x%0h, dut=0x%0h",
               ref_data, tr.out_byte))
         end

         // 3) Compare parity bit
         ref_par = ref_model.get_parity_bit();
         dut_par = tr.full_frame[9];
         if (ref_par !== dut_par) begin
            scoreboard_passed = 0;
            `uvm_error("SBD", $sformatf(
               "Mismatch in parity bit: ref=%b, dut=%b",
                ref_par, dut_par))
         end

         // 4) Compare stop bit
         ref_stop = ref_model.get_stop_bit();
         if (ref_stop !== tr.stop_bit) begin
            scoreboard_passed = 0;
            `uvm_error("SBD", $sformatf(
               "Mismatch in stop bit: ref=%b, dut=%b",
               ref_stop, tr.stop_bit))
         end

         // 5) Compare final "done"
         ref_done_val = ref_model.get_ref_done();
         if (ref_done_val !== tr.done) begin
            scoreboard_passed = 0;
            `uvm_error("SBD", $sformatf(
               "Mismatch in done: ref=%b, dut=%b",
               ref_done_val, tr.done))
         end

         // If all fields matched, we log a pass
         if (scoreboard_passed) begin
            `uvm_info("SBD", $sformatf(
               "Scoreboard PASS: full frame match, out_byte=0x%0h, done=%b",
                tr.out_byte, tr.done), UVM_LOW)
         end
      end
   endtask: run_phase

endclass: serialDP_sbd

`endif // SERIALDP_SBD__SV
