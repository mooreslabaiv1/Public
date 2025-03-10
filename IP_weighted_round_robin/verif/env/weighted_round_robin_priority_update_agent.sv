`ifndef WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT__SV
`define WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT__SV

class weighted_round_robin_priority_update_agent extends uvm_agent;

   protected uvm_active_passive_enum is_active = UVM_ACTIVE;
   weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

   weighted_round_robin_prio_update_driver drv;
   weighted_round_robin_prio_update_monitor mon;

   // The priority interface for driving prio, prio_id, prio_upt
   typedef virtual prio_update_if vif_prio_update_if;
   vif_prio_update_if agt_prio_update_if;

   typedef virtual requestor_if #(32, $clog2(32)) req_vif_t;
   req_vif_t req_vif;  // This is so the priority driver can see ack

   `uvm_component_utils_begin(weighted_round_robin_priority_update_agent)
   `uvm_component_utils_end

   function new(string name = "mast_agt", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      mon = weighted_round_robin_prio_update_monitor::type_id::create("mon", this);

      if (is_active == UVM_ACTIVE) begin
         priority_update_seqr = weighted_round_robin_priority_update_agent_base_seqr::type_id::create("priority_update_seqr", this);
         drv = weighted_round_robin_prio_update_driver::type_id::create("drv", this);
      end

      // Get the priority interface
      if (!uvm_config_db#(vif_prio_update_if)::get(this, "", "vif", agt_prio_update_if)) begin
         `uvm_fatal("AGT/NOVIF", "No virtual prio_update_if specified for this agent instance")
      end

      // SET that interface to the driver & monitor
      uvm_config_db#(vif_prio_update_if)::set(this, "drv", "vif", agt_prio_update_if);
      uvm_config_db#(vif_prio_update_if)::set(this, "mon", "vif", agt_prio_update_if);
      uvm_config_db#(vif_prio_update_if)::set(this, "priority_update_seqr", "drv_if", agt_prio_update_if);

      // GET the requestor_if so the driver can see ack
      if (!uvm_config_db#(req_vif_t)::get(this, "", "req_vif", req_vif)) begin
         `uvm_info("AGT/NO_REQIF","No requestor_if provided. Priority driver won't see ack.", UVM_LOW)
      end else begin
         // If we successfully got req_vif, pass it to the driver
         uvm_config_db#(req_vif_t)::set(this, "drv", "req_vif", req_vif);
      end
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if (is_active == UVM_ACTIVE) begin
         drv.seq_item_port.connect(priority_update_seqr.seq_item_export);
      end
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
   endfunction

endclass: weighted_round_robin_priority_update_agent

`endif // WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT__SV