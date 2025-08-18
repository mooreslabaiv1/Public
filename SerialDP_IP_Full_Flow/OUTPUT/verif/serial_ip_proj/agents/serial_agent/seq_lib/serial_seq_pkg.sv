

package serial_seq_pkg;

  //******************************************************************************
  // Imports
  //******************************************************************************
  import uvm_pkg::*;
  import serial_agent_pkg::*;

  //******************************************************************************
  // Includes
  //******************************************************************************
  `include "serial_base_seq.sv"
  `include "serial_start_bit_detection_test_sequence.sv"
  `include "serial_data_bit_reception_test_sequence.sv"
  `include "serial_odd_parity_check_test_sequence.sv"
  `include "serial_stop_bit_verification_test_sequence.sv"
  `include "serial_parity_error_detection_test_sequence.sv"
  `include "serial_stop_bit_error_detection_test_sequence.sv"
  `include "serial_full_byte_reception_with_valid_signals_sequence.sv"

endpackage : serial_seq_pkg