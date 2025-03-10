


`ifndef SERIALDP_ENV_CFG__SV
`define SERIALDP_ENV_CFG__SV

class serialDP_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: serialDP_env_cfg

function serialDP_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // SERIALDP_ENV_CFG__SV