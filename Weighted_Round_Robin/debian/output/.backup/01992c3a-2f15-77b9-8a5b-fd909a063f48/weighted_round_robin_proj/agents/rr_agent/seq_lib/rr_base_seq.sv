`ifndef RR_BASE_SEQ__SV
`define RR_BASE_SEQ__SV

class rr_base_sequence extends uvm_sequence #(rr_trans_item);

  // Factory Registration
  `uvm_object_utils(rr_base_sequence)

  // Constructor
  function new(string name = "rr_base_seq");
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

endclass : rr_base_sequence

`endif  // RR_BASE_SEQ__SV