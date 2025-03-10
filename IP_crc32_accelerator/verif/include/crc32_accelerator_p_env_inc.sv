

    `ifndef CRC32_ACCELERATOR_P_ENV_INC_SV
    `define CRC32_ACCELERATOR_P_ENV_INC_SV
    `include "tb_src.incl"    
    `include "crc32_accelerator_p_env_cfg.sv"
    `include "crc32_accelerator_p_reference_model.sv"
    `include "crc32_accelerator_p_sbd.sv"
    
    `include "crc32_accelerator_p_crc32_accelerator_monitor_env_cov.sv"
    `include "crc32_accelerator_p_crc32_accelerator_monitor_connect_cov.sv"
        
    `endif // CRC32_ACCELERATOR_P_ENV_INC_SV
    