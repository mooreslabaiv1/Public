


`ifndef FSM_ONE_HOT_FSM_MONITOR_ENV_COV__SV
`define FSM_ONE_HOT_FSM_MONITOR_ENV_COV__SV

class fsm_one_hot_fsm_monitor_env_cov extends uvm_component;
   event cov_event;
   fsm_one_hot_fsm_agent_base_transaction tr;
   uvm_analysis_imp #(fsm_one_hot_fsm_agent_base_transaction, fsm_one_hot_fsm_monitor_env_cov) cov_export;
   `uvm_component_utils(fsm_one_hot_fsm_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function void write(fsm_one_hot_fsm_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: fsm_one_hot_fsm_monitor_env_cov

`endif // FSM_ONE_HOT_FSM_MONITOR_ENV_COV__SV