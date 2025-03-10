



`ifndef FSM_ONE_HOT_FSM_AGENT_BASE_SEQR__SV
`define FSM_ONE_HOT_FSM_AGENT_BASE_SEQR__SV


typedef class fsm_one_hot_fsm_agent_base_transaction;
class fsm_one_hot_fsm_agent_base_seqr extends uvm_sequencer # (fsm_one_hot_fsm_agent_base_transaction);

   `uvm_component_utils(fsm_one_hot_fsm_agent_base_seqr)

   virtual fsm_if fsm_vif;

   function new (string name,
                 uvm_component parent);
      super.new(name,parent);
   endfunction:new 

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual fsm_if)::get(this, "", "fsm_agent_fsm_if", fsm_vif)) begin
         `uvm_fatal("No VIF","No fsm_agent_fsm_if found for sequencer")
      end
   endfunction

endclass:fsm_one_hot_fsm_agent_base_seqr

`endif // FSM_ONE_HOT_FSM_AGENT_BASE_SEQR__SV