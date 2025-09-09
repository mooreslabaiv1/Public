`ifndef WRR_PRIO_UPDATE_BASE_SEQ__SV
`define WRR_PRIO_UPDATE_BASE_SEQ__SV

class wrr_prio_update_base_sequence extends uvm_sequence #(wrr_prio_update_trans_item);

  // Factory Registration
  `uvm_object_utils(wrr_prio_update_base_sequence)

  // Constructor
  function new(string name = "wrr_prio_update_base_seq");
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

endclass : wrr_prio_update_base_sequence

`endif  // WRR_PRIO_UPDATE_BASE_SEQ__SV