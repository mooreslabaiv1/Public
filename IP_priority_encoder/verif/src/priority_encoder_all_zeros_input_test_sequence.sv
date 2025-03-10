

class priority_encoder_base_sequence extends uvm_sequence #(priority_encoder_priority_encoder_agent_base_transaction);

   function new(string name="priority_encoder_base_sequence");
      super.new(name);
   endfunction

   task body();

   endtask

endclass : priority_encoder_base_sequence

class priority_encoder_all_zeros_input_test_sequence extends priority_encoder_base_sequence;
  `uvm_object_utils(priority_encoder_all_zeros_input_test_sequence)

  function new(string name="priority_encoder_all_zeros_input_test_sequence");
    super.new(name);
  endfunction

  task body();
    priority_encoder_priority_encoder_agent_base_transaction req;
    req = priority_encoder_priority_encoder_agent_base_transaction::type_id::create("req");
    start_item(req);
    req.sa = 4'b0000;
    finish_item(req);
  endtask
endclass
