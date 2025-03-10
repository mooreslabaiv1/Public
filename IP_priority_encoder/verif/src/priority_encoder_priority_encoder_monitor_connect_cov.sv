

`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_CONNECT_COV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_CONNECT_COV
class priority_encoder_priority_encoder_monitor_connect_cov extends uvm_component;
   priority_encoder_priority_encoder_monitor_env_cov cov;
   uvm_analysis_export # (priority_encoder_priority_encoder_agent_base_transaction) an_exp;
   `uvm_component_utils(priority_encoder_priority_encoder_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(priority_encoder_priority_encoder_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: priority_encoder_priority_encoder_monitor_connect_cov

`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR_CONNECT_COV