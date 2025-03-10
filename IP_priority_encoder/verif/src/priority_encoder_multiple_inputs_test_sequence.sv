


// Added seq_item class
class multiple_inputs_test_seq_item extends priority_encoder_priority_encoder_agent_base_transaction;
  `uvm_object_utils(multiple_inputs_test_seq_item)
  rand logic [3:0] in_data;

  function new(string name="multiple_inputs_test_seq_item");
    super.new(name);
  endfunction
endclass


class multiple_inputs_test_sequence extends uvm_sequence #(priority_encoder_priority_encoder_agent_base_transaction);
  `uvm_object_utils(multiple_inputs_test_sequence)

  function new(string name="multiple_inputs_test_sequence");
    super.new(name);
  endfunction

  task body();
    multiple_inputs_test_seq_item seq_item;

    for (int i = 0; i < 20; i++) begin
        seq_item = multiple_inputs_test_seq_item::type_id::create($sformatf("seq_item_%0d", i), null);

        if (!seq_item.randomize() with {
            $countones(in_data) >= 2; // Ensure at least 2 bits are high
        }) begin
            `uvm_error("SEQUENCE", $sformatf("Randomization failed for item %0d", i));
        end

        `uvm_info("SEQUENCE", $sformatf("Randomized in_data = %b for item %0d", seq_item.in_data, i), UVM_LOW);

        // Start and finish the sequence item
        start_item(seq_item);
        finish_item(seq_item);

    end

  endtask
endclass