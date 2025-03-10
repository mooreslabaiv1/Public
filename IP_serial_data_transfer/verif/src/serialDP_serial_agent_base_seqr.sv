


`ifndef SERIALDP_SERIAL_AGENT_BASE_SEQR__SV
`define SERIALDP_SERIAL_AGENT_BASE_SEQR__SV


typedef class serialDP_serial_agent_base_transaction;
class serialDP_serial_agent_base_seqr extends uvm_sequencer # (serialDP_serial_agent_base_transaction);

   `uvm_component_utils(serialDP_serial_agent_base_seqr)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:serialDP_serial_agent_base_seqr

`endif // SERIALDP_SERIAL_AGENT_BASE_SEQR__SV