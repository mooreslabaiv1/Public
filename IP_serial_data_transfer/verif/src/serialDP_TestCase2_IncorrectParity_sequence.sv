class serialDP_base_transaction extends serialDP_serial_agent_base_transaction;
  `uvm_object_utils(serialDP_base_transaction)
  function new(string name="serialDP_base_transaction");
    super.new(name);
  endfunction
endclass : serialDP_base_transaction

class serialDP_incorrect_parity_transaction extends serialDP_base_transaction;
  rand bit do_reset;
  rand int reset_cycles;
  rand bit start_bit;
  rand logic [7:0] data_bits;
  rand bit parity_bit;
  rand bit stop_bit;

  `uvm_object_utils(serialDP_incorrect_parity_transaction)

  function new(string name="serialDP_incorrect_parity_transaction");
    super.new(name);
  endfunction
endclass : serialDP_incorrect_parity_transaction

class serialDP_base_sequence extends uvm_sequence #(serialDP_base_transaction);

  function new(string name="serialDP_base_sequence");
    super.new(name);
  endfunction

  task body();
    // Default base sequence body (can be empty or minimal)
  endtask

endclass : serialDP_base_sequence


class serialDP_TestCase2_IncorrectParity_sequence extends base_sequence;

  `uvm_object_utils(serialDP_TestCase2_IncorrectParity_sequence)

  function new(string name = "serialDP_TestCase2_IncorrectParity_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    serialDP_serial_agent_base_transaction tr;
    serialDP_serial_agent_base_transaction trc;
    uvm_phase local_phase = starting_phase;

    if (local_phase != null)
      local_phase.raise_objection(this, 
        "Starting serialDP_TestCase2_IncorrectParity_sequence");

    // Create a transaction that intentionally requests a bad parity bit
    tr = new("tr_incorrect_parity");
    tr.kind   = serialDP_serial_agent_base_transaction::WRITE;
    tr.status = serialDP_serial_agent_base_transaction::ERROR; // "force incorrect parity"
    tr.sa     = 8'h5A; // Example data. The driver will invert the correct parity bit.

    start_item(tr);
    finish_item(tr);
  
    trc = new("tr_correct_parity");
  
    trc.kind   = serialDP_serial_agent_base_transaction::WRITE;
    trc.status = serialDP_serial_agent_base_transaction::IS_OK;
    trc.sa     = 8'hF0; // 10101001 => 5 ones => odd parity

    start_item(trc);
    finish_item(trc);

    if (local_phase != null)
      local_phase.drop_objection(this, 
        "Ending serialDP_TestCase2_IncorrectParity_sequence");

  endtask : body

endclass : serialDP_TestCase2_IncorrectParity_sequence