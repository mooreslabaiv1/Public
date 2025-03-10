`ifndef WEIGHTED_ROUND_ROBIN_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define WEIGHTED_ROUND_ROBIN_BASE_SEQR_SEQUENCE_LIBRARY__SV

class weighted_round_robin_base_seqr_sequence_library extends uvm_sequence_library #(weighted_round_robin_requestor_agent_base_transaction);

  `uvm_object_utils(weighted_round_robin_base_seqr_sequence_library)
  `uvm_sequence_library_utils(weighted_round_robin_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass

// Define base sequence classes

class weighted_round_robin_base_sequence extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(weighted_round_robin_base_sequence)

  function new(string name = "weighted_round_robin_base_sequence");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
    set_automatic_phase_objection(1);
    `endif
  endfunction:new

endclass

class weighted_round_robin_requestor_base_sequence extends uvm_sequence #(weighted_round_robin_requestor_agent_base_transaction);
  `uvm_object_utils(weighted_round_robin_requestor_base_sequence)
  `uvm_declare_p_sequencer(weighted_round_robin_requestor_agent_base_seqr)

  function new(string name = "weighted_round_robin_requestor_base_sequence");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
    set_automatic_phase_objection(1);
    `endif
  endfunction:new

endclass

class weighted_round_robin_priority_update_base_sequence extends uvm_sequence #(weighted_round_robin_priority_update_agent_base_transaction);
  `uvm_object_utils(weighted_round_robin_priority_update_base_sequence)
  `uvm_declare_p_sequencer(weighted_round_robin_priority_update_agent_base_seqr)

  function new(string name = "weighted_round_robin_priority_update_base_sequence");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
    set_automatic_phase_objection(1);
    `endif
  endfunction:new

endclass

`endif // WEIGHTED_ROUND_ROBIN_BASE_SEQR_SEQUENCE_LIBRARY__SV