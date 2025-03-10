

   `ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT__SV
   `define PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT__SV
   
   
   class priority_encoder_priority_encoder_agent extends uvm_agent;
      // <Optional> ToDo: add uvm agent properties here
      protected uvm_active_passive_enum is_active = UVM_ACTIVE;
      priority_encoder_priority_encoder_agent_base_seqr base_sqr;
      
      priority_encoder_priority_encoder_driver drv;
      priority_encoder_priority_encoder_monitor mon;
      typedef virtual priority_encoder_if vif_priority_encoder_if;
      vif_priority_encoder_if agt_priority_encoder_if;          

   
      `uvm_component_utils_begin(priority_encoder_priority_encoder_agent)
      //<Optional> ToDo: add field utils macros here if required
   	`uvm_component_utils_end
   
         // <Optional> ToDo: Add required short hand override method
   
      function new(string name = "mast_agt", uvm_component parent = null);
         super.new(name, parent);
      endfunction
   
      virtual function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         
         mon = priority_encoder_priority_encoder_monitor::type_id::create("mon", this);
         if (is_active == UVM_ACTIVE) begin
            base_sqr = priority_encoder_priority_encoder_agent_base_seqr::type_id::create("base_sqr", this);
            drv = priority_encoder_priority_encoder_driver::type_id::create("drv", this);
         end
         if (!uvm_config_db#(vif_priority_encoder_if)::get(this, "", "priority_encoder_agent_priority_encoder_if", agt_priority_encoder_if)) begin
            `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
         end
         uvm_config_db# (vif_priority_encoder_if)::set(this,"drv","priority_encoder_agent_priority_encoder_if", agt_priority_encoder_if);
         uvm_config_db# (vif_priority_encoder_if)::set(this,"mon","priority_encoder_agent_priority_encoder_if", agt_priority_encoder_if);

      endfunction: build_phase
   
      virtual function void connect_phase(uvm_phase phase);
         super.connect_phase(phase);
         
         if (is_active == UVM_ACTIVE) begin
      		  drv.seq_item_port.connect(base_sqr.seq_item_export);
         end

      endfunction
   
      virtual task run_phase(uvm_phase phase);
         super.run_phase(phase);
         // phase.raise_objection(this,"slv_agt_run"); //Raise/drop objections in sequence file
   
         // <Optional> ToDo : Implement here
   
         // phase.drop_objection(this);
      endtask
   
      virtual function void report_phase(uvm_phase phase);
         super.report_phase(phase);
   
         // <Optional> ToDo : Implement here
   
      endfunction
   
   endclass: priority_encoder_priority_encoder_agent
   
   `endif // PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT__SV
   