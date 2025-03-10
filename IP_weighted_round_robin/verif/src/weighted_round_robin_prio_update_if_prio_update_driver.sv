`ifndef WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_DRIVER__SV
`define WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_DRIVER__SV

class weighted_round_robin_prio_update_driver
   extends uvm_driver #(weighted_round_robin_priority_update_agent_base_transaction);

   // Priority interface
   typedef virtual prio_update_if v_if; 
   v_if drv_if;

   // ADD: Requestor interface to see ack
   typedef virtual requestor_if #(32, $clog2(32)) req_vif_t;
   req_vif_t req_if;

   function new(
      string name = "weighted_round_robin_prio_update_driver", 
      uvm_component parent = null
   );
      super.new(name, parent);
   endfunction

   `uvm_component_utils_begin(weighted_round_robin_prio_update_driver)
   `uvm_component_utils_end

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      // Priority interface
      if (!uvm_config_db#(v_if)::get(this, "", "vif", drv_if)) begin
         `uvm_fatal("NOVIF", "Virtual prio_update_if not set for priority driver")
      end

      // Requestor interface (for ack)
      if (!uvm_config_db#(req_vif_t)::get(this, "", "req_vif", req_if)) begin
         // Not strictly fatal if user doesn't care about ack gating
         `uvm_info("NO_REQ_VIF","No requestor_if found for priority driver; ack gating won't work",UVM_LOW)
      end
   endfunction

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      if (drv_if == null)
         `uvm_fatal("NO_CONN", "Priority IF not connected.");
      // req_if could be null if user didn't set it, but let's keep going.
   endfunction

   // Reset all signals during reset_phase
   virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      drv_if.prio     <= '0;
      drv_if.prio_id  <= '0;
      drv_if.prio_upt <= 1'b0;
   endtask: reset_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork 
         tx_driver();
      join_none
   endtask: run_phase

   //-----------------------------------------------------------------------------
   // Key modification: Wait until ack is low before sending a new priority update
   //-----------------------------------------------------------------------------
   protected virtual task tx_driver();
      int rand_delay = $urandom_range(0, 5);
      weighted_round_robin_priority_update_agent_base_transaction tr;

      // Wait for reset de-assertion
      @(negedge drv_if.rst);

      // Wait a few clock cycles for stability
      repeat (3) @(posedge drv_if.clk);

      forever begin
         // Clear prio_upt
         drv_if.prio_upt <= 1'b0;
         @(posedge drv_if.clk);

         // Get the next transaction from the sequence
         seq_item_port.get_next_item(tr);

         // If we have a valid req_if, wait for ack to be low
         if (req_if != null) begin
            while (req_if.ack == 1'b1) begin
               @(posedge drv_if.clk);
            end
         end

         // Add a random delay (0..5 cycles) to vary update timing
         repeat (rand_delay) @(posedge drv_if.clk);

         // Now it's safe to send the new priority
         send(tr);

         seq_item_port.item_done();
      end
   endtask : tx_driver

   //-----------------------------------------------------------------------------
   // "send": drive the prio, prio_id, and pulse prio_upt for one clock
   //-----------------------------------------------------------------------------
   protected virtual task send(weighted_round_robin_priority_update_agent_base_transaction tr);
      logic [3:0] prio_value      = tr.prio;
      logic [4:0] prio_id_value   = tr.prio_id;
      logic       prio_upt_value = tr.prio_upt;

      drv_if.prio     <= prio_value;
      drv_if.prio_id  <= prio_id_value;
      drv_if.prio_upt <= prio_upt_value;

      // Wait one clock to latch the new priority
      @(posedge drv_if.clk);
      // Deassert prio_upt
      drv_if.prio_upt <= 1'b0;
   endtask: send

endclass: weighted_round_robin_prio_update_driver

`endif // WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_DRIVER__SV
