`ifndef SERIALDP_SERIAL_IF_DRIVER__SV
`define SERIALDP_SERIAL_IF_DRIVER__SV

import uvm_pkg::*;
`include "serialDP_serial_agent_transaction.sv"
// ^ This must define serialDP_serial_agent_base_transaction 
//   with fields like full_frame, stop_bit, etc.

typedef virtual interface serial_if vif_t;

class serialDP_serial_if_driver extends uvm_driver #(serialDP_serial_agent_base_transaction);

   // A handle to the SystemVerilog interface
   vif_t drv_if;

   `uvm_component_utils_begin(serialDP_serial_if_driver)
   `uvm_component_utils_end

   //--------------------------------------------------------------------------
   // Constructor
   //--------------------------------------------------------------------------
   function new(string name="serialDP_serial_if_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   //--------------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   //--------------------------------------------------------------------------
   // connect_phase
   //--------------------------------------------------------------------------
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Pull the interface from the UVM config DB
      if (!uvm_config_db#(vif_t)::get(this, "", "serial_agent_serial_if", drv_if)) begin
         `uvm_fatal("DRV_NO_IF",{"No serial_if found in config DB for ", get_full_name()})
      end
   endfunction: connect_phase

   //--------------------------------------------------------------------------
   // end_of_elaboration_phase
   //--------------------------------------------------------------------------
   virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      if (drv_if == null) begin
         `uvm_fatal("NO_VIF","No valid virtual interface connected to driver!")
      end
   endfunction: end_of_elaboration_phase

   //--------------------------------------------------------------------------
   // run_phase
   //   We fork a main loop that waits for transactions
   //--------------------------------------------------------------------------
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         tx_driver();
      join
   endtask: run_phase

   //--------------------------------------------------------------------------
   // tx_driver: main driver loop
   //--------------------------------------------------------------------------
   protected virtual task tx_driver();
      serialDP_serial_agent_base_transaction tr;
      // Ensure the line is idle=1 at the start
      drv_if.in = 1;
      @(posedge drv_if.clk);
      while (drv_if.rst) @(posedge drv_if.clk);

      forever begin
         seq_item_port.get_next_item(tr);
         send(tr);
         seq_item_port.item_done();
      end
   endtask: tx_driver

   //--------------------------------------------------------------------------
   // send: generate signals for READ or WRITE transaction
   //--------------------------------------------------------------------------
   protected virtual task send(serialDP_serial_agent_base_transaction tr);
      bit pbit;
      int cycle_count = 0;
      localparam int MAX_WAIT_DONE = 100;
      `uvm_info("DRV_SEND", $sformatf("Driver got transaction: %s", tr.sprint()), UVM_LOW)

      case (tr.kind)

         //========================================================
         // READ transaction: simple approach => wait for done=1
         //========================================================
         serialDP_serial_agent_base_transaction::READ: begin
            // If we want to "read" from the DUT, we typically wait
            // for done=1, then capture out_byte
            while (!drv_if.done) @(posedge drv_if.clk);
            tr.out_byte = drv_if.out_byte;
            tr.done     = drv_if.done;
         end

         //========================================================
         // WRITE transaction: send start/data/parity/stop
         // and fill tr.full_frame[], tr.stop_bit
         //========================================================
         serialDP_serial_agent_base_transaction::WRITE: begin
            // Keep line idle=1 for a cycle
            drv_if.in = 1;
            @(posedge drv_if.clk);

            // 1) Start bit = 0
            drv_if.in = 0;
            tr.full_frame[0] = 0; // record start bit
            @(posedge drv_if.clk);

            // 2) Send 8 data bits (LSB-first), store them in the transaction
            for (int i = 0; i < 8; i++) begin
               bit bit_val = tr.sa[i]; // LSB is sa[0]
               drv_if.in         = bit_val;
               tr.full_frame[i+1]= bit_val; // i+1 => data bits in [1..8]
               @(posedge drv_if.clk);
            end

            // 3) Compute parity bit for odd parity
            pbit = compute_odd_parity_8(tr.sa);

            // If user wants to force error, invert it
            if (tr.status == serialDP_serial_agent_base_transaction::ERROR) begin
               pbit = ~pbit;
            end

            drv_if.in          = pbit;
            tr.full_frame[9]   = pbit;  // store in the transaction
            @(posedge drv_if.clk);

            // 4) Stop bit = 1
            drv_if.in   = 1;
            tr.stop_bit = 1;
            @(posedge drv_if.clk);

            // Optionally remain idle for a cycle
            @(posedge drv_if.clk);

            // Since the DUT is receiving, it might eventually set done=1
            // if parity & stop check out. We could capture that here:
            while ((!drv_if.done) && (!drv_if.rst) && (cycle_count < MAX_WAIT_DONE)) begin
               @(posedge drv_if.clk);
               cycle_count++;
            end
            tr.done     = drv_if.done;
            tr.out_byte = drv_if.out_byte;
         end
      endcase
   endtask: send

   //--------------------------------------------------------------------------
   // compute_odd_parity_8
   //   Returns 1 if 'data' has an even # of 1 bits,
   //   so total # (data + this bit) is odd.
   //--------------------------------------------------------------------------
   protected function bit compute_odd_parity_8(byte data);
      int count_ones = 0;
      for (int i=0; i<8; i++) begin
         if (data[i]) count_ones++;
      end
      // If count is even, pbit=1 => overall odd
      // If count is odd, pbit=0 => overall odd
      return (count_ones % 2) == 0;
   endfunction: compute_odd_parity_8

endclass: serialDP_serial_if_driver

`endif // SERIALDP_SERIAL_IF_DRIVER__SV
