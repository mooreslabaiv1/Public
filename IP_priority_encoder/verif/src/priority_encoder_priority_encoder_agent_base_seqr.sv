

`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_BASE_SEQR__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_BASE_SEQR__SV


typedef class priority_encoder_priority_encoder_agent_base_transaction;
class priority_encoder_priority_encoder_agent_base_seqr extends uvm_sequencer # (priority_encoder_priority_encoder_agent_base_transaction);

   `uvm_component_utils(priority_encoder_priority_encoder_agent_base_seqr)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:priority_encoder_priority_encoder_agent_base_seqr

`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_BASE_SEQR__SV