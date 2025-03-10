

`ifndef CRC32_ACCELERATOR_P_REFERENCE_MODEL__SV
`define CRC32_ACCELERATOR_P_REFERENCE_MODEL__SV

class crc32_accelerator_p_reference_model extends uvm_component;
   
   // Internal CRC register
   logic [31:0] crc_reg;

   `uvm_component_utils(crc32_accelerator_p_reference_model)

   extern function new(string name, uvm_component parent);
   extern virtual task main_phase(uvm_phase phase);
   extern function void reset();
   extern function void calculate_crc(logic [7:0] data_in);

endclass: crc32_accelerator_p_reference_model

function crc32_accelerator_p_reference_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction

function void crc32_accelerator_p_reference_model::reset();
   crc_reg = 32'hFFFF_FFFF;
endfunction

function void crc32_accelerator_p_reference_model::calculate_crc(logic [7:0] data_in);
   int i;
   crc_reg ^= data_in;
   for (i = 0; i < 8; i++) begin
      if (crc_reg[0])
         crc_reg = (crc_reg >> 1) ^ 32'hEDB88320;
      else
         crc_reg = crc_reg >> 1;
   `uvm_info("CRC_ref", $sformatf("data_in = 0x%h\n  crc_reg = 0x%h\n",
                              data_in,
                              crc_reg), UVM_LOW);
   end


endfunction

task crc32_accelerator_p_reference_model::main_phase(uvm_phase phase);
   super.main_phase(phase);
endtask

`endif // CRC32_ACCELERATOR_P_REFERENCE_MODEL__SV