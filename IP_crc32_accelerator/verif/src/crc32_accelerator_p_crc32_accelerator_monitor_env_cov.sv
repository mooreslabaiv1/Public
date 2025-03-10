
`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_ENV_COV__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_ENV_COV__SV

class crc32_accelerator_p_crc32_accelerator_monitor_env_cov extends uvm_component;
   event cov_event;
   crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;
   uvm_analysis_imp #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction, crc32_accelerator_p_crc32_accelerator_monitor_env_cov) cov_export;
   `uvm_component_utils(crc32_accelerator_p_crc32_accelerator_monitor_env_cov)
 
   covergroup cg_trans @(cov_event);
      // <Optional> ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: crc32_accelerator_p_crc32_accelerator_monitor_env_cov

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR_ENV_COV__SV

