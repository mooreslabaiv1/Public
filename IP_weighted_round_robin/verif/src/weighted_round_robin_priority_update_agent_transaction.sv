

`ifndef WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT_TRANSACTION__SV
`define WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT_TRANSACTION__SV

class weighted_round_robin_priority_update_agent_base_transaction extends uvm_sequence_item;

   rand logic [3:0] prio;
   rand logic [4:0] prio_id;
   rand logic       prio_upt;

   // constraints
   constraint c_prio_range    { prio    inside {[0:15]}; }
   constraint c_prio_id_range { prio_id inside {[0:31]}; }

   `uvm_object_utils_begin(weighted_round_robin_priority_update_agent_base_transaction) 
      `uvm_field_int(prio, UVM_ALL_ON)
      `uvm_field_int(prio_id, UVM_ALL_ON)
      `uvm_field_int(prio_upt, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "Trans");
      super.new(name);
   endfunction: new

endclass: weighted_round_robin_priority_update_agent_base_transaction

`endif // WEIGHTED_ROUND_ROBIN_PRIORITY_UPDATE_AGENT_TRANSACTION__SV