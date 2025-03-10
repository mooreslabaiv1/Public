

`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_CONNECT_COV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_CONNECT_COV
class fsm_seek_detect_fsm_seek_detect_monitor_connect_cov extends uvm_component;
   fsm_seek_detect_fsm_seek_detect_monitor_env_cov cov;
   uvm_analysis_export # (fsm_seek_detect_fsm_seek_detect_agent_base_transaction) an_exp;
   `uvm_component_utils(fsm_seek_detect_fsm_seek_detect_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: fsm_seek_detect_fsm_seek_detect_monitor_connect_cov

`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR_CONNECT_COV