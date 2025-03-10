

`ifndef CRC32_ACCELERATOR_P_ENV_TB_MOD__SV
`define CRC32_ACCELERATOR_P_ENV_TB_MOD__SV
`include "interfaces.incl"
module crc32_accelerator_p_tb_top;

`define UVM_NO_DEPRECATED
`define UVM_OBJECT_MUST_HAVE_CONSTRUCTOR

import uvm_pkg::*;

`include "crc32_accelerator_p_env.sv"
`include "All_zeros_test.sv"
`include "All_ones_test.sv"
`include "Multiple_Byte_Sequence_test.sv"
`include "Idle_State_Maintenance_test.sv"
`include "crc32_accelerator_p_env_test.sv"
`include "Reset_Behavior_test.sv"

// Include all other test list here
               

typedef virtual crc32_accelerator_if vif_crc32_accelerator_if;


// Clock and reset signals - Do not remove the below clk, rst registers
reg clk;
reg rst;

// Do not remove the below the clock, reset generation. You can only change the time delay as per the design requirements
// Clock generation
initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

// Reset generation
string uvm_testname;
initial begin
  if ($value$plusargs("UVM_TESTNAME=%s", uvm_testname)) begin
    if (uvm_testname == "Reset_Behavior_test") begin
      rst = 1;
      repeat(5) @(posedge clk); // Assert for 5 clock cycles
      rst = 0;
      repeat(10) @(posedge clk); // Deassert for 10 clock cycles
      rst = 1;
      repeat(5) @(posedge clk); // Assert for 5 clock cycles
      rst = 0;
    end else begin
      rst = 1;
      #10 rst = 0;
    end
  end else begin
    rst = 1;
    #10 rst = 0;
  end
end

// Optional: If you need to generate clocks, resets in a different domain do it below  

// Do the DUT instantiation below
crc32_accelerator_p dut (
  .clk(clk),
  .rst(rst),
  .data_in(crc32_accelerator_if_inst.data_in),
  .data_valid(crc32_accelerator_if_inst.data_valid),
  .crc_out(crc32_accelerator_if_inst.crc_out),
  .crc_valid(crc32_accelerator_if_inst.crc_valid)
);

// Connect the generated clock, reset to all the required interfaces
crc32_accelerator_if crc32_accelerator_if_inst(clk, rst);

initial begin
  
  uvm_config_db #(vif_crc32_accelerator_if)::set(null,"*", "vif", crc32_accelerator_if_inst);

  run_test();
end

// Do not add any stimulus here it will be taken care of in the UVM driver

// Do not edit the below code
initial begin
      $dumpfile("testbench.vcd");
      $dumpvars(0, crc32_accelerator_p_tb_top);
end    

endmodule: crc32_accelerator_p_tb_top

`endif // CRC32_ACCELERATOR_P_ENV_TB_MOD__SV