//---------------------------------------------------------
// Base sequence definition (if none exists) and new test sequence
//---------------------------------------------------------
class base_sequence extends uvm_sequence #(serialDP_serial_agent_base_transaction);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
  endfunction : new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask : pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : post_body
  `endif

  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting base_sequence");
  endtask : pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending base_sequence");
  endtask : post_start
  `endif

endclass : base_sequence


class TestCase1_CorrectParity_sequence extends base_sequence;
  `uvm_object_utils(TestCase1_CorrectParity_sequence)

  function new(string name = "TestCase1_CorrectParity_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    serialDP_serial_agent_base_transaction tr;
    uvm_phase local_phase;
    local_phase = starting_phase;
    tr = new("test_tr");

    if (local_phase != null)
      local_phase.raise_objection(this, "Starting TestCase1_CorrectParity_sequence");

    tr.kind   = serialDP_serial_agent_base_transaction::WRITE;
    tr.status = serialDP_serial_agent_base_transaction::IS_OK;
    tr.sa     = 8'hA9; // 10101001 => 5 ones => odd parity

    start_item(tr);
    finish_item(tr);
    
    if (local_phase != null)
      local_phase.drop_objection(this, "Ending TestCase1_CorrectParity_sequence");
  endtask : body

endclass : TestCase1_CorrectParity_sequence