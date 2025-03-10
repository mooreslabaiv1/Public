

`ifndef WEIGHTED_ROUND_ROBIN_ENV_INC__SV
`define WEIGHTED_ROUND_ROBIN_ENV_INC__SV
`include "tb_src.incl"    
`include "weighted_round_robin_env_cfg.sv"
// Include the reference model here
`include "weighted_round_robin_ref_model.sv"
`include "weighted_round_robin_sbd.sv"

`include "weighted_round_robin_requestor_monitor_env_cov.sv"
`include "weighted_round_robin_requestor_monitor_connect_cov.sv"

`include "weighted_round_robin_prio_update_monitor_env_cov.sv"
`include "weighted_round_robin_prio_update_monitor_connect_cov.sv"

`endif // WEIGHTED_ROUND_ROBIN_ENV_INC__SV