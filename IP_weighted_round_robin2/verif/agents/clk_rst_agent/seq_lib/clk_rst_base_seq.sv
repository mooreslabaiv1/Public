`ifndef CLK_RST_BASE_SEQ__SV
`define CLK_RST_BASE_SEQ__SV

class clk_rst_base_sequence extends uvm_sequence #(clk_rst_trans_item);
  clk_rst_trans_item tr;

  // Factory Registration
  `uvm_object_utils(clk_rst_base_sequence)

  // Constructor
  function new(string name = "clk_rst_base_seq");
    super.new(name);
  endfunction : new

  //******************************************************************************
  // Body
  //******************************************************************************
  virtual task body();
    `uvm_info(get_full_name(), $sformatf("Starting sequence body in %s ...", get_type_name()), UVM_LOW)
    tr = clk_rst_trans_item::type_id::create("tr");

    start_item(tr);
    if (!tr.randomize() with {op_type == CLK_SET;})
      `uvm_error("CLK_SET", "\nRandomization failed\n")
    finish_item(tr);

    start_item(tr);
    if (!tr.randomize() with {op_type == RST_APPLY;})
      `uvm_error("RST_APPLY", "\nRandomization failed\n")
    finish_item(tr);
  endtask : body

endclass : clk_rst_base_sequence

`endif // CLK_RST_BASE_SEQ__SV