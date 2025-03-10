

`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_ENV_COV__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_ENV_COV__SV

class priority_encoder_priority_encoder_monitor_env_cov extends uvm_component;
   event cov_event;
   priority_encoder_priority_encoder_agent_base_transaction tr;
   uvm_analysis_imp #(priority_encoder_priority_encoder_agent_base_transaction, priority_encoder_priority_encoder_monitor_env_cov) cov_export;
   `uvm_component_utils(priority_encoder_priority_encoder_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function void write(priority_encoder_priority_encoder_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: priority_encoder_priority_encoder_monitor_env_cov

`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_ENV_COV__SV