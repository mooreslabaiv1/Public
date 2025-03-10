

`ifndef FSM_SEEK_DETECT_ENV_CFG__SV
`define FSM_SEEK_DETECT_ENV_CFG__SV

class fsm_seek_detect_env_cfg extends uvm_object; 

   extern function new(string name = "");
  
endclass: fsm_seek_detect_env_cfg

function fsm_seek_detect_env_cfg::new(string name = "");
   super.new(name);
endfunction: new


`endif // FSM_SEEK_DETECT_ENV_CFG__SV