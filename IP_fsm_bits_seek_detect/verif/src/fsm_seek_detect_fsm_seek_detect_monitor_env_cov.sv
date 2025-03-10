

`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_ENV_COV__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_ENV_COV__SV

class fsm_seek_detect_fsm_seek_detect_monitor_env_cov extends uvm_component;
   event cov_event;
   fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr;
   uvm_analysis_imp #(fsm_seek_detect_fsm_seek_detect_agent_base_transaction, fsm_seek_detect_fsm_seek_detect_monitor_env_cov) cov_export;
   `uvm_component_utils(fsm_seek_detect_fsm_seek_detect_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function void write(fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: fsm_seek_detect_fsm_seek_detect_monitor_env_cov

`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_ENV_COV__SV