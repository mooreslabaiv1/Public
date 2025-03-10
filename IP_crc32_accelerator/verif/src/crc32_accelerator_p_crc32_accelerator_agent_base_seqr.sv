

`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_BASE_SEQR__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_BASE_SEQR__SV

class crc32_accelerator_p_crc32_accelerator_agent_base_seqr extends uvm_sequencer # (crc32_accelerator_p_crc32_accelerator_agent_base_transaction);

   `uvm_component_utils(crc32_accelerator_p_crc32_accelerator_agent_base_seqr)
   function new (string name,
                 uvm_component parent);
      super.new(name,parent);
   endfunction:new 
endclass:crc32_accelerator_p_crc32_accelerator_agent_base_seqr

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT_BASE_SEQR__SV