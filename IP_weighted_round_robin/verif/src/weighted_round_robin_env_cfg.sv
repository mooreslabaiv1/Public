
`ifndef WEIGHTED_ROUND_ROBIN_ENV_CFG__SV
`define WEIGHTED_ROUND_ROBIN_ENV_CFG__SV

class weighted_round_robin_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: weighted_round_robin_env_cfg

function weighted_round_robin_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // WEIGHTED_ROUND_ROBIN_ENV_CFG__SV
