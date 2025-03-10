

`ifndef WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_TRANSACTION__SV
`define WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_TRANSACTION__SV

class weighted_round_robin_requestor_agent_base_transaction extends uvm_sequence_item;

   rand logic [31:0] req;
   logic [4:0]       gnt_id;
   logic             ack;

   `uvm_object_utils_begin(weighted_round_robin_requestor_agent_base_transaction) 
      `uvm_field_int(req, UVM_ALL_ON)
      `uvm_field_int(gnt_id, UVM_ALL_ON)
      `uvm_field_int(ack, UVM_ALL_ON)  // Register ack
   `uvm_object_utils_end

   function new(string name = "Trans");
      super.new(name);
   endfunction

endclass: weighted_round_robin_requestor_agent_base_transaction

`endif // WEIGHTED_ROUND_ROBIN_REQUESTOR_AGENT_TRANSACTION__SV