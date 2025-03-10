
`ifndef WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_CONNECT_COV
`define WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_CONNECT_COV
class weighted_round_robin_prio_update_monitor_connect_cov extends uvm_component;
   weighted_round_robin_prio_update_monitor_env_cov cov;
   uvm_analysis_export # (weighted_round_robin_priority_update_agent_base_transaction) an_exp;
   `uvm_component_utils(weighted_round_robin_prio_update_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(weighted_round_robin_priority_update_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: weighted_round_robin_prio_update_monitor_connect_cov

`endif // WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_MONITOR_CONNECT_COV

