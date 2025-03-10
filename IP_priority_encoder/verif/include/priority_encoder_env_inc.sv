


    `ifndef PRIORITY_ENCODER_ENV_INC_SV
    `define PRIORITY_ENCODER_ENV_INC_SV
    `include "tb_src.incl"    
    `include "priority_encoder_env_cfg.sv"
    // Include the reference model here
    `include "priority_encoder_ref_model.sv"
    `include "priority_encoder_sbd.sv"
    
    `include "priority_encoder_priority_encoder_monitor_env_cov.sv"
    `include "priority_encoder_priority_encoder_monitor_connect_cov.sv"

    // <Optional> ToDo: Add additional required `include directives
    
    `endif // PRIORITY_ENCODER_ENV_INC_SV
    