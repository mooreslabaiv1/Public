
`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_CONNECT_COV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_CONNECT_COV
class crc32_accelerator_p_crc32_accelerator_monitor_connect_cov extends uvm_component;
   crc32_accelerator_p_crc32_accelerator_monitor_env_cov cov;
   uvm_analysis_export # (crc32_accelerator_p_crc32_accelerator_agent_base_transaction) an_exp;
   `uvm_component_utils(crc32_accelerator_p_crc32_accelerator_monitor_connect_cov)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: crc32_accelerator_p_crc32_accelerator_monitor_connect_cov

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_CONNECT_COV

