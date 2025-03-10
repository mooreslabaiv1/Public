

`ifndef CRC32_ACCELERATOR_P_BASE_SEQR_SEQUENCE_LIBRARY__SV
`define CRC32_ACCELERATOR_P_BASE_SEQR_SEQUENCE_LIBRARY__SV

typedef class crc32_accelerator_p_crc32_accelerator_agent_base_transaction;
class crc32_accelerator_p_base_seqr_sequence_library extends uvm_sequence_library # (crc32_accelerator_p_crc32_accelerator_agent_base_transaction);

  `uvm_object_utils(crc32_accelerator_p_base_seqr_sequence_library)
  `uvm_sequence_library_utils(crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask:pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask:post_body
  `endif

  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting");
  endtask:pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending");
  endtask:post_start
  `endif
endclass

// =====================================
// Test Sequence: Multiple Byte Sequence
// Description: Validate the CRC calculation for a sequence of bytes.
// =====================================
class Multiple_Byte_Sequence extends base_sequence;
  `uvm_object_utils(Multiple_Byte_Sequence)
  `uvm_add_to_seq_lib(Multiple_Byte_Sequence, crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "Multiple_Byte_Sequence");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    string message;
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;
    int i;

    message = "Hello World\n";

    foreach (message[i]) begin
      tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("tr");
      tr.data_in = message[i];
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end
  endtask:body
endclass

// =====================================
// Test Sequence: Idle State Maintenance
// Description: Ensure the module maintains consistent state when no data is provided.
// =====================================
class Idle_State_Maintenance extends base_sequence;
  `uvm_object_utils(Idle_State_Maintenance)
  `uvm_add_to_seq_lib(Idle_State_Maintenance, crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "Idle_State_Maintenance");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;
    int i;

    // Step 1: Send 5 valid data transactions.
    for (i = 0; i < 5; i++) begin
      tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("tr");
      tr.data_in = $random;
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end

    // Step 2: Hold data_valid low.
    // No transactions sent, simulate idle time.
    #50;

    // Step 5: Send 5 more valid data transactions.
    for (i = 0; i < 5; i++) begin
      tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("tr");
      tr.data_in = $random;
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end
  endtask:body
endclass

// =====================================
// Test Sequence: All ones
// Description: Check behavior when all the input data is 0xFF.
// =====================================
class All_ones extends base_sequence;
  `uvm_object_utils(All_ones)
  `uvm_add_to_seq_lib(All_ones, crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "All_ones");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    All_ones_transaction tr;
    int i;

    // Step 1: Send 5 valid data transactions with data_in = 0xFF
    for (i = 0; i < 5; i++) begin
      tr = All_ones_transaction::type_id::create("tr");
      tr.data_in = 8'hFF;
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end

    // Step 2: Hold data_valid low.
    // No transactions sent, simulate idle time.
    #50;

  endtask:body
endclass

// =====================================
// Test Sequence: All zeros
// Description: Check behavior when all the input data is 0.
// =====================================
class All_zeros extends base_sequence;
  `uvm_object_utils(All_zeros)
  `uvm_add_to_seq_lib(All_zeros, crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "All_zeros");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    All_zeros_transaction tr;
    int i;

    // Step 1: Send 5 valid data transactions with data_in = 0x00
    for (i = 0; i < 5; i++) begin
      tr = All_zeros_transaction::type_id::create("tr");
      tr.data_in = 8'h00;
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end

    // Step 2: Hold data_valid low.
    // No transactions sent, simulate idle time.
    #50;

  endtask:body
endclass

// =====================================
// Test Sequence: Reset Behavior
// Description: Check if the CRC module initializes correctly on reset.
// =====================================
class Reset_Behavior extends base_sequence;
  `uvm_object_utils(Reset_Behavior)
  `uvm_add_to_seq_lib(Reset_Behavior, crc32_accelerator_p_base_seqr_sequence_library)

  function new(string name = "Reset_Behavior");
    super.new(name);
    `ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;
    int i;

    // Step 1: Send 20 valid data transactions.
    for (i = 0; i < 20; i++) begin
      tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("tr");
      tr.data_in = $random;
      tr.data_valid = 1;
      start_item(tr);
      finish_item(tr);
    end
  endtask:body
endclass

`endif // CRC32_ACCELERATOR_P_BASE_SEQR_SEQUENCE_LIBRARY__SV