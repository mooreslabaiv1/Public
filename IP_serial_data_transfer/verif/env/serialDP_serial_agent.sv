


   `ifndef SERIALDP_SERIAL_AGENT__SV
   `define SERIALDP_SERIAL_AGENT__SV
   
   
   class serialDP_serial_agent extends uvm_agent;
      protected uvm_active_passive_enum is_active = UVM_ACTIVE;
      serialDP_serial_agent_base_seqr base_sqr;
      
      serialDP_serial_if_driver drv;
      serialDP_serial_if_monitor mon;
      typedef virtual serial_if vif_serial_if;
      vif_serial_if agt_serial_if;          

   
      `uvm_component_utils_begin(serialDP_serial_agent)
   	`uvm_component_utils_end
   
      function new(string name = "mast_agt", uvm_component parent = null);
         super.new(name, parent);
      endfunction
   
      virtual function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         
         mon = serialDP_serial_if_monitor::type_id::create("mon", this);
         if (is_active == UVM_ACTIVE) begin
            base_sqr = serialDP_serial_agent_base_seqr::type_id::create("base_sqr", this);
            drv = serialDP_serial_if_driver::type_id::create("drv", this);
         end
         if (!uvm_config_db#(vif_serial_if)::get(this, "", "serial_agent_serial_if", agt_serial_if)) begin
            `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
         end
         uvm_config_db# (vif_serial_if)::set(this,"drv","serial_agent_serial_if",drv.drv_if);
         uvm_config_db# (vif_serial_if)::set(this,"mon","serial_agent_serial_if",mon.mon_if);

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
   
   endclass: serialDP_serial_agent
   
   `endif // SERIALDP_SERIAL_AGENT__SV
   
   