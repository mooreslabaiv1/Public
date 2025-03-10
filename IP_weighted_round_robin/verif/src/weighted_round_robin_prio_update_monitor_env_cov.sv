
`ifndef WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_ENV_COV__SV
`define WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_ENV_COV__SV

class weighted_round_robin_prio_update_monitor_env_cov extends uvm_component;
   event cov_event;
   weighted_round_robin_priority_update_agent_base_transaction tr;
   uvm_analysis_imp #(weighted_round_robin_priority_update_agent_base_transaction, weighted_round_robin_prio_update_monitor_env_cov) cov_export;
   `uvm_component_utils(weighted_round_robin_prio_update_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(weighted_round_robin_priority_update_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: weighted_round_robin_prio_update_monitor_env_cov

`endif // WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_ENV_COV__SV

