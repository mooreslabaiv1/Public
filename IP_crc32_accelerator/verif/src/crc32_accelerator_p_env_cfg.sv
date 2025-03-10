
`ifndef CRC32_ACCELERATOR_P_ENV_CFG__SV
`define CRC32_ACCELERATOR_P_ENV_CFG__SV

class crc32_accelerator_p_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: crc32_accelerator_p_env_cfg

function crc32_accelerator_p_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // CRC32_ACCELERATOR_P_ENV_CFG__SV
