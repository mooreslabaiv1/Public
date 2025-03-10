

`ifndef PRIORITY_ENCODER_ENV_CFG__SV
`define PRIORITY_ENCODER_ENV_CFG__SV

class priority_encoder_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: priority_encoder_env_cfg

function priority_encoder_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // PRIORITY_ENCODER_ENV_CFG__SV