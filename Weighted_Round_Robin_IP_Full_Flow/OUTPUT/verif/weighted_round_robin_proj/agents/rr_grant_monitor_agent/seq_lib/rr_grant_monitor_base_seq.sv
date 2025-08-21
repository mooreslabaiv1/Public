
`ifndef RR_GRANT_MONITOR_BASE_SEQ__SV
`define RR_GRANT_MONITOR_BASE_SEQ__SV

class rr_grant_monitor_base_sequence extends uvm_sequence #(rr_grant_monitor_trans_item);

  // Factory Registration
  `uvm_object_utils(rr_grant_monitor_base_sequence)

  // Sequence item instance
  rr_grant_monitor_trans_item tr;

  // Constructor
  function new(string name = "rr_grant_monitor_base_seq");
    super.new(name);
  endfunction : new

  //******************************************************************************
  // Body
  //******************************************************************************
  virtual task body();
    `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()), UVM_LOW)
    repeat (80) begin
      `uvm_do(tr);
    end
  endtask : body

endclass : rr_grant_monitor_base_sequence

`endif  // RR_GRANT_MONITOR_BASE_SEQ__SV