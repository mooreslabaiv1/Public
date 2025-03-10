


`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_TRANSACTION__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_TRANSACTION__SV

class crc32_accelerator_p_crc32_accelerator_agent_base_transaction extends uvm_sequence_item;

  rand logic [7:0] data_in;
  rand logic       data_valid;
  logic [31:0]     crc_out;
  logic            crc_valid;

  `uvm_object_utils_begin(crc32_accelerator_p_crc32_accelerator_agent_base_transaction)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(data_valid, UVM_ALL_ON)
    `uvm_field_int(crc_out, UVM_ALL_ON)
    `uvm_field_int(crc_valid, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "Trans");
endclass: crc32_accelerator_p_crc32_accelerator_agent_base_transaction

function crc32_accelerator_p_crc32_accelerator_agent_base_transaction::new(string name = "Trans");
  super.new(name);
endfunction: new

// =====================================
// Transaction Class: All ones transaction
// Description: Transaction class for the All ones test sequence.
// =====================================
class All_ones_transaction extends crc32_accelerator_p_crc32_accelerator_agent_base_transaction;
  `uvm_object_utils(All_ones_transaction)

  function new(string name = "All_ones_transaction");
    super.new(name);
  endfunction: new

endclass: All_ones_transaction

// =====================================
// Transaction Class: All zeros transaction
// Description: Transaction class for the All zeros test sequence.
// =====================================
class All_zeros_transaction extends crc32_accelerator_p_crc32_accelerator_agent_base_transaction;
  `uvm_object_utils(All_zeros_transaction)

  function new(string name = "All_zeros_transaction");
    super.new(name);
  endfunction: new

endclass: All_zeros_transaction

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_TRANSACTION__SV