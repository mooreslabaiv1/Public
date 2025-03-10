


`ifndef FSM_ONE_HOT_ENV_CFG__SV
`define FSM_ONE_HOT_ENV_CFG__SV

class fsm_one_hot_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: fsm_one_hot_env_cfg

function fsm_one_hot_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // FSM_ONE_HOT_ENV_CFG__SV