

`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_BASE_SEQR__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_BASE_SEQR__SV


typedef class fsm_seek_detect_fsm_seek_detect_agent_base_transaction;
class fsm_seek_detect_fsm_seek_detect_agent_base_seqr extends uvm_sequencer # (fsm_seek_detect_fsm_seek_detect_agent_base_transaction);

   `uvm_component_utils(fsm_seek_detect_fsm_seek_detect_agent_base_seqr)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:fsm_seek_detect_fsm_seek_detect_agent_base_seqr

`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_BASE_SEQR__SV