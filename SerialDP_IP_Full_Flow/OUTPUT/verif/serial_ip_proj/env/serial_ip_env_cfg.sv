`ifndef SERIAL_IP_ENV_CFG__SV
`define SERIAL_IP_ENV_CFG__SV

class serial_ip_env_cfg extends uvm_object;

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "");
    super.new(name);
  endfunction : new

endclass : serial_ip_env_cfg

`endif  // SERIAL_IP_ENV_CFG__SV