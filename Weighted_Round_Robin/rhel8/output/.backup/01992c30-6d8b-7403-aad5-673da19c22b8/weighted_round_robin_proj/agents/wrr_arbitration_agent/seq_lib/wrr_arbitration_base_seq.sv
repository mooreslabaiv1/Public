`ifndef WRR_ARBITRATION_BASE_SEQ__SV
`define WRR_ARBITRATION_BASE_SEQ__SV

class wrr_arbitration_base_sequence extends uvm_sequence #(wrr_arbitration_trans_item);

  // Factory Registration
  `uvm_object_utils(wrr_arbitration_base_sequence)

  // Constructor
  function new(string name = "wrr_arbitration_base_seq");
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

endclass : wrr_arbitration_base_sequence

`endif  // WRR_ARBITRATION_BASE_SEQ__SV