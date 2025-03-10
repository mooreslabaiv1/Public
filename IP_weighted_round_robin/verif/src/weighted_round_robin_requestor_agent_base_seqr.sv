

`ifndef WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_BASE_SEQR__SV
`define WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_BASE_SEQR__SV

class weighted_round_robin_requestor_agent_base_seqr extends uvm_sequencer # (weighted_round_robin_requestor_agent_base_transaction);

   typedef virtual requestor_if v_if;
   v_if drv_if;

   `uvm_component_utils(weighted_round_robin_requestor_agent_base_seqr)
   
   function new (string name,
                 uvm_component parent);
      super.new(name,parent);
   endfunction:new 

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(v_if)::get(this, "", "drv_if", drv_if)) begin
         `uvm_warning("SEQNODRVIF", "No 'drv_if' provided to sequencer.")
      end
   endfunction: build_phase

endclass:weighted_round_robin_requestor_agent_base_seqr

`endif // WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_BASE_SEQR__SV