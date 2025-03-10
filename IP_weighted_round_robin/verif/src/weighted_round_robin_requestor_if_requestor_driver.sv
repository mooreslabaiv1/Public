`ifndef WEIGHTED_ROUND_ROBIN_REQUESTOR_DRIVER__SV
`define WEIGHTED_ROUND_ROBIN_REQUESTOR_DRIVER__SV

class weighted_round_robin_requestor_driver extends uvm_driver #(weighted_round_robin_requestor_agent_base_transaction);

   typedef virtual requestor_if v_if; 
   v_if drv_if;

   function new(string name = "weighted_round_robin_requestor_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   `uvm_component_utils_begin(weighted_round_robin_requestor_driver)
   `uvm_component_utils_end

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(v_if)::get(this, "", "vif", drv_if)) begin
         `uvm_fatal("NOVIF", "Virtual interface not set for driver")
      end
   endfunction: connect_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      if (drv_if == null)
         `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
   endfunction: end_of_elaboration_phase

   virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      // Reset output signals
      drv_if.req <= '0;
      drv_if.ack <= 1'b0; // Initialize ack to 0
   endtask: reset_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork 
         tx_driver();
      join_none
   endtask: run_phase

   protected virtual task tx_driver();
      weighted_round_robin_requestor_agent_base_transaction tr;
      // Wait for reset de-assertion
      @(negedge drv_if.rst);
      // Wait for 3 clock cycles
      repeat (3) @(posedge drv_if.clk);
      drv_if.req <= '0;
      forever begin
         // Set outputs to their idle state

         drv_if.ack <= 1'b0;

         // Get next transaction
         seq_item_port.get_next_item(tr);

         // Send the transaction request
         send(tr);

         // Wait for grant to stabilize
         @(posedge drv_if.clk);
         if (drv_if.gnt_w != '0) begin
            drv_if.ack <= 1'b1; // Assert ack for valid grant
            @(posedge drv_if.clk);
            drv_if.ack <= 1'b0; // Deassert ack after one clock
         end else begin
            drv_if.ack <= 1'b0; // Ensure ack is low if no valid grant
         end

         seq_item_port.item_done();
      end
   endtask : tx_driver

   protected virtual task send(weighted_round_robin_requestor_agent_base_transaction tr);
      logic [31:0] req_value;
      req_value = tr.req;
      drv_if.req <= req_value;
   endtask: send

endclass: weighted_round_robin_requestor_driver

`endif // WEIGHTED_ROUND_ROBIN_REQUESTOR_DRIVER__SV
