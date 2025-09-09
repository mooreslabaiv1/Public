`ifndef WEIGHTED_ROUND_ROBIN_ENV_CFG__SV
`define WEIGHTED_ROUND_ROBIN_ENV_CFG__SV

class weighted_round_robin_env_cfg extends uvm_object;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "");
    super.new(name);
  endfunction : new

endclass : weighted_round_robin_env_cfg

`endif  // WEIGHTED_ROUND_ROBIN_ENV_CFG__SV