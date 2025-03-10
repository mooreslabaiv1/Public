




   `ifndef FSM_ONE_HOT_FSM_AGENT__SV
   `define FSM_ONE_HOT_FSM_AGENT__SV
   
   
   class fsm_one_hot_fsm_agent extends uvm_agent;
      protected uvm_active_passive_enum is_active = UVM_ACTIVE;
      fsm_one_hot_fsm_agent_base_seqr base_sqr;
      
      fsm_one_hot_fsm_driver drv;
      fsm_one_hot_fsm_monitor mon;
      typedef virtual fsm_if vif_fsm_if;
      vif_fsm_if agt_fsm_if;          

   
      `uvm_component_utils_begin(fsm_one_hot_fsm_agent)
   	`uvm_component_utils_end
   
      function new(string name = "mast_agt", uvm_component parent = null);
         super.new(name, parent);
      endfunction

      function vif_fsm_if get_fsm_if();
         return agt_fsm_if;
      endfunction: get_fsm_if
   
      virtual function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         
         mon = fsm_one_hot_fsm_monitor::type_id::create("mon", this);
         if (is_active == UVM_ACTIVE) begin
            base_sqr = fsm_one_hot_fsm_agent_base_seqr::type_id::create("base_sqr", this);
            drv = fsm_one_hot_fsm_driver::type_id::create("drv", this);
         end
         if (!uvm_config_db#(vif_fsm_if)::get(this, "", "fsm_agent_fsm_if", agt_fsm_if)) begin
            `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
         end
         uvm_config_db# (vif_fsm_if)::set(this,"drv","fsm_agent_fsm_if",agt_fsm_if);
         uvm_config_db# (vif_fsm_if)::set(this,"mon","fsm_agent_fsm_if",agt_fsm_if);
      endfunction: build_phase
   
      virtual function void connect_phase(uvm_phase phase);
         super.connect_phase(phase);
         
         if (is_active == UVM_ACTIVE) begin
      		  drv.seq_item_port.connect(base_sqr.seq_item_export);
         end
      endfunction
   
      virtual task run_phase(uvm_phase phase);
         super.run_phase(phase);
      endtask
   
      virtual function void report_phase(uvm_phase phase);
         super.report_phase(phase);
      endfunction
   
   endclass: fsm_one_hot_fsm_agent
   
   `endif // FSM_ONE_HOT_FSM_AGENT__SV
   