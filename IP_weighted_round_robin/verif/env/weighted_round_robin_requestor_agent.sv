



`ifndef WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT__SV
`define WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT__SV

class weighted_round_robin_requestor_agent extends uvm_agent;
   protected uvm_active_passive_enum is_active = UVM_ACTIVE;
   weighted_round_robin_requestor_agent_base_seqr requestor_seqr;

   weighted_round_robin_requestor_driver drv;
   weighted_round_robin_requestor_monitor mon;
   typedef virtual requestor_if vif_requestor_if;
   vif_requestor_if agt_requestor_if;          

   `uvm_component_utils_begin(weighted_round_robin_requestor_agent)
   `uvm_component_utils_end

   function new(string name = "mast_agt", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      mon = weighted_round_robin_requestor_monitor::type_id::create("mon", this);
      if (is_active == UVM_ACTIVE) begin
         requestor_seqr = weighted_round_robin_requestor_agent_base_seqr::type_id::create("requestor_seqr", this);
         drv = weighted_round_robin_requestor_driver::type_id::create("drv", this);
      end
      if (!uvm_config_db#(vif_requestor_if)::get(this, "", "vif", agt_requestor_if)) begin
         `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
      end
      uvm_config_db# (vif_requestor_if)::set(this,"drv","vif", agt_requestor_if);
      uvm_config_db# (vif_requestor_if)::set(this,"mon","vif", agt_requestor_if);
      uvm_config_db# (vif_requestor_if)::set(this,"requestor_seqr","drv_if", agt_requestor_if);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      if (is_active == UVM_ACTIVE) begin
         drv.seq_item_port.connect(requestor_seqr.seq_item_export);
      end

   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
   endfunction

endclass: weighted_round_robin_requestor_agent

`endif // WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT__SV