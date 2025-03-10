



`ifndef WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR__SV
`define WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR__SV

import uvm_pkg::*; 

class weighted_round_robin_prio_update_monitor extends uvm_monitor;

   uvm_analysis_port #(weighted_round_robin_priority_update_agent_base_transaction) mon_analysis_port;  // TLM analysis port
   typedef virtual prio_update_if v_if;
   v_if mon_if;

   function new(string name = "weighted_round_robin_prio_update_monitor", uvm_component parent);
      super.new(name, parent);
      mon_analysis_port = new ("mon_analysis_port", this);
   endfunction: new

   `uvm_component_utils_begin(weighted_round_robin_prio_update_monitor)
   `uvm_component_utils_end

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(v_if)::get(this, "", "vif", mon_if)) begin
         `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
      end
   endfunction: connect_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         tx_monitor();
      join_none
   endtask: run_phase

   protected virtual task tx_monitor();
      weighted_round_robin_priority_update_agent_base_transaction tr;
      // Wait for reset de-assertion
      @(negedge mon_if.rst);
      forever begin
         // Wait for transaction event (e.g., posedge of clock)
         @(posedge mon_if.clk);
         tr = weighted_round_robin_priority_update_agent_base_transaction::type_id::create("tr");
         tr.prio = mon_if.prio;
         tr.prio_id = mon_if.prio_id;
         tr.prio_upt = mon_if.prio_upt;
         // Send transaction via analysis port
         mon_analysis_port.write(tr);
      end
   endtask: tx_monitor

endclass: weighted_round_robin_prio_update_monitor

`endif // WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR__SV