

package serial_ip_test_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import serial_ip_env_pkg::*;
  import serial_seq_pkg::*;
  import clk_rst_seq_pkg::*;
  import serial_agent_pkg::*;
  import clk_rst_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "serial_ip_base_test.sv"
  `include "serial_ip_mid_sim_rst_test.sv"
  `include "serial_ip_start_bit_detection_test.sv"
  `include "serial_ip_data_bit_reception_test.sv"
  `include "serial_ip_odd_parity_check_test.sv"
  `include "serial_ip_stop_bit_verification_test.sv"
  `include "serial_ip_parity_error_detection_test.sv"
  `include "serial_ip_stop_bit_error_detection_test.sv"
  `include "serial_ip_full_byte_reception_with_valid_signals.sv"

endpackage : serial_ip_test_pkg