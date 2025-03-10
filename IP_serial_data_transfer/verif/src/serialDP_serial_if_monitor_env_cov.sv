


`ifndef SERIALDP_SERIAL_IF_MONITOR_ENV_COV__SV
`define SERIALDP_SERIAL_IF_MONITOR_ENV_COV__SV

class serialDP_serial_if_monitor_env_cov extends uvm_component;
   event cov_event;
   serialDP_serial_agent_base_transaction tr;
   uvm_analysis_imp #(serialDP_serial_agent_base_transaction, serialDP_serial_if_monitor_env_cov) cov_export;
   `uvm_component_utils(serialDP_serial_if_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function void write(serialDP_serial_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: serialDP_serial_if_monitor_env_cov

`endif // SERIALDP_SERIAL_IF_MONITOR_ENV_COV__SV