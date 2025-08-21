
`ifndef CLK_RST_TRANS_ITEM__SV
`define CLK_RST_TRANS_ITEM__SV

class clk_rst_trans_item extends uvm_sequence_item;

  //******************************************************************************
  // Variables
  //******************************************************************************
  rand op_type_t op_type;
  rand int       period;
  rand int       div_clk_shift;
  rand int       divider;
  rand int       rst_wait_cycles;
  rand int       rst_shift;
  rand int       wait_clk_cycles;
  int            reset_asserted;
  int            reset_deasserted;

  //******************************************************************************
  // Constraints
  //******************************************************************************
  constraint clk_rst_trans_item_base {
    period inside {4, 6, 8};
    divider inside {2, 3};
    div_clk_shift >= 0;
    div_clk_shift <= period;
    rst_wait_cycles inside {[6:9]};
    rst_shift >= 0;
    rst_shift <= period;
    wait_clk_cycles >= 1;
  }

  //******************************************************************************
  // Factory registration
  //******************************************************************************
  `uvm_object_utils_begin(clk_rst_trans_item)
    `uvm_field_enum(op_type_t, op_type, UVM_ALL_ON)
    `uvm_field_int(period, UVM_ALL_ON)
    `uvm_field_int(div_clk_shift, UVM_ALL_ON)
    `uvm_field_int(divider, UVM_ALL_ON)
    `uvm_field_int(rst_wait_cycles, UVM_ALL_ON)
    `uvm_field_int(rst_shift, UVM_ALL_ON)
    `uvm_field_int(wait_clk_cycles, UVM_ALL_ON)
    `uvm_field_int(reset_asserted, UVM_ALL_ON)
    `uvm_field_int(reset_deasserted, UVM_ALL_ON)
  `uvm_object_utils_end

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "clk_rst_trans_item");
    super.new(name);
  endfunction : new

endclass : clk_rst_trans_item

`endif  // CLK_RST_TRANS_ITEM__SV