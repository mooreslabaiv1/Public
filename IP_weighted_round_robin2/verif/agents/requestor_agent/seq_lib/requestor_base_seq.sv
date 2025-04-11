`ifndef REQUESTOR_BASE_SEQ__SV
`define REQUESTOR_BASE_SEQ__SV

class requestor_base_sequence extends uvm_sequence #(requestor_trans_item);

  // Factory Registration
  `uvm_object_utils(requestor_base_sequence)

  // Constructor
  function new(string name = "requestor_base_seq");
    super.new(name);
  endfunction : new

  //******************************************************************************
  // Body
  //******************************************************************************
  virtual task body();
    `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()), UVM_LOW)
    repeat (80) begin
      `uvm_do(req);
    end
  endtask : body

endclass : requestor_base_sequence

`endif  // REQUESTOR_BASE_SEQ__SV