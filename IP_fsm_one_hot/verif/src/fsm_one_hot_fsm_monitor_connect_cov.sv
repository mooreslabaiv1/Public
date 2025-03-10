


`ifndef FSM_ONE_HOT_FSM_MONITOR_CONNECT_COV
`define FSM_ONE_HOT_FSM_MONITOR_CONNECT_COV
class fsm_one_hot_fsm_monitor_connect_cov extends uvm_component;
   fsm_one_hot_fsm_monitor_env_cov cov;
   uvm_analysis_export # (fsm_one_hot_fsm_agent_base_transaction) an_exp;
   `uvm_component_utils(fsm_one_hot_fsm_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(fsm_one_hot_fsm_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: fsm_one_hot_fsm_monitor_connect_cov

`endif // FSM_ONE_HOT_FSM_MONITOR_CONNECT_COV