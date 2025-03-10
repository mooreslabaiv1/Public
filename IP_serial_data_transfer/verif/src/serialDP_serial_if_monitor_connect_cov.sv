


`ifndef SERIALDP_SERIAL_IF_MONITOR_CONNECT_COV
`define SERIALDP_SERIAL_IF_MONITOR_CONNECT_COV
class serialDP_serial_if_monitor_connect_cov extends uvm_component;
   serialDP_serial_if_monitor_env_cov cov;
   uvm_analysis_export # (serialDP_serial_agent_base_transaction) an_exp;
   `uvm_component_utils(serialDP_serial_if_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(serialDP_serial_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: serialDP_serial_if_monitor_connect_cov

`endif // SERIALDP_SERIAL_IF_MONITOR_CONNECT_COV