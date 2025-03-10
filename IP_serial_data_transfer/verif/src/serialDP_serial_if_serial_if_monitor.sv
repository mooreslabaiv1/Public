`ifndef SERIALDP_SERIAL_IF_MONITOR__SV
`define SERIALDP_SERIAL_IF_MONITOR__SV

import uvm_pkg::*;
`include "serialDP_serial_agent_transaction.sv"

//========================================================
// CLASS: serialDP_serial_if_monitor
//
// Monitors the serial line for start/data/parity/stop,
// uses timeouts to avoid hanging if `done` never asserts
// or if the line never returns idle, and then sends a
// transaction to the scoreboard.
//
// All variables are declared at the top of the class or
// at the top of each task/function, as requested.
//========================================================
class serialDP_serial_if_monitor extends uvm_monitor;

   // -------------------------------------------------------
   // 1) Class properties at the top
   // -------------------------------------------------------
   uvm_analysis_port #(serialDP_serial_agent_base_transaction) mon_analysis_port;

   // Virtual interface
   typedef virtual serial_if vif_t;
   vif_t mon_if;

   // Local buffers for the captured bits
   bit [9:0] frame_bits; // [0]=start, [1..8]=data, [9]=parity
   bit       stop_b;

   // Timeout settings
   int max_wait_done;  // number of clock cycles to wait for done=1
   int max_wait_idle;  // number of clock cycles to wait for line=1 (idle)

   `uvm_component_utils_begin(serialDP_serial_if_monitor)
   `uvm_component_utils_end

   // -------------------------------------------------------
   // CONSTRUCTOR
   // -------------------------------------------------------
   function new(string name = "serialDP_serial_if_monitor",
                uvm_component parent = null);
      super.new(name, parent);

      // Analysis port
      mon_analysis_port = new("mon_analysis_port", this);

      // Default timeouts
      max_wait_done = 100;
      max_wait_idle = 100;
   endfunction: new

   // -------------------------------------------------------
   // build_phase
   // -------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   // -------------------------------------------------------
   // connect_phase
   // -------------------------------------------------------
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(vif_t)::get(this, "", "serial_agent_serial_if", mon_if)) begin
         `uvm_fatal("MON_NO_IF",{"No virtual interface provided to ", get_full_name()})
      end
   endfunction: connect_phase

   // -------------------------------------------------------
   // run_phase
   // -------------------------------------------------------
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         monitor_task();
      join
   endtask: run_phase

   // -------------------------------------------------------
   // monitor_task
   // -------------------------------------------------------
   protected virtual task monitor_task();

      // Declare local loop counters, transaction var, etc. at top
      int i;
      int count;
      int count_idle;
      serialDP_serial_agent_base_transaction tr;

      // Wait for reset deassert
      @(posedge mon_if.clk);
      while (mon_if.rst) @(posedge mon_if.clk);

      forever begin
         // ===================================================
         // A) Wait for line=1 (idle), with a timeout
         // ===================================================
         wait_for_line_idle();  // this sub-task also has all vars at top

         // ===================================================
         // B) Wait for line=0 => start bit
         // ===================================================
         while (mon_if.in == 1) @(posedge mon_if.clk); // block until start

         frame_bits[0] = 0; // start bit

         // ===================================================
         // C) Shift in 9 bits => 8 data + 1 parity
         // ===================================================
         for (i = 1; i <= 9; i++) begin
            @(posedge mon_if.clk);
            frame_bits[i] = mon_if.in;
         end

         // ===================================================
         // D) Capture stop bit
         // ===================================================
         @(posedge mon_if.clk);
         stop_b = mon_if.in;

         // ===================================================
         // E) Wait up to max_wait_done for done==1
         // ===================================================
         count=0;
         while ((mon_if.done == 0) && (count < max_wait_done)) begin
            @(posedge mon_if.clk);
            count++;
         end

         // If done never went high => mon_if.done still 0
         // Create a transaction, fill fields
         tr = new("rx_frame");
         tr.full_frame = frame_bits;
         tr.stop_bit   = stop_b;
         tr.out_byte   = mon_if.out_byte;
         tr.done       = mon_if.done; // 1 if it occurred, else 0
         tr.kind       = serialDP_serial_agent_base_transaction::READ;

         // Send transaction to scoreboard
         mon_analysis_port.write(tr);

         // ===================================================
         // F) If done=1, wait for it to deassert
         //    else wait up to max_wait_idle for line=1
         // ===================================================
         if (mon_if.done == 1) begin
            while (mon_if.done == 1) @(posedge mon_if.clk);
         end else begin
            // The DUT never asserted done => assume error
            count_idle=0;
            while ((mon_if.in == 0) && (count_idle < max_wait_idle)) begin
               @(posedge mon_if.clk);
               count_idle++;
            end
            // If line is still 0 after max_wait_idle => we move on
         end

      end // forever
   endtask: monitor_task

   // -------------------------------------------------------
   // wait_for_line_idle: waits up to 'max_wait_idle' cycles
   // for mon_if.in==1
   // -------------------------------------------------------
   protected task wait_for_line_idle();
      int cyc;
      cyc = 0;
      while ((mon_if.in == 0) && (cyc < max_wait_idle)) begin
         @(posedge mon_if.clk);
         cyc++;
      end
      // If still 0 after cyc==max_wait_idle => we exit anyway
   endtask: wait_for_line_idle

endclass: serialDP_serial_if_monitor

`endif // SERIALDP_SERIAL_IF_MONITOR__SV