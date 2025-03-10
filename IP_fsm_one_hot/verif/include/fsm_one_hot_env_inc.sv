



    `ifndef FSM_ONE_HOT_ENV_INC_SV
    `define FSM_ONE_HOT_ENV_INC_SV
    `include "tb_src.incl"    
    `include "fsm_one_hot_env_cfg.sv"
    // Include the reference model here
    `include "fsm_one_hot_ref_model.sv"
    
    `include "fsm_one_hot_fsm_monitor_env_cov.sv"
    `include "fsm_one_hot_fsm_monitor_connect_cov.sv"


    // <Optional> ToDo: Add additional required `include directives
    
    `endif // FSM_ONE_HOT_ENV_INC_SV
    