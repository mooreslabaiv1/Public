



`ifndef PRIORITY_ENCODER_ENV_TB_MOD__SV
`define PRIORITY_ENCODER_ENV_TB_MOD__SV
`include "interfaces.incl"
module priority_encoder_tb_top;

import uvm_pkg::*;

`include "priority_encoder_env.sv"
`include "priority_encoder_env_test.sv"

`include "multiple_inputs_test_test.sv"
`include "single_input_test_test.sv"
`include "all_zeros_input_test_test.sv"
`include "reset_functionality_test_test.sv"

   typedef virtual priority_encoder_if vif_priority_encoder_if;


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
  initial begin
    rst = 1;
    #10 rst = 0;
  end

  // Optional: If you need to generate clocks, resets in a different domain do it below  

  // TODO: Do the DUT instantiation below
  
  // Interface instance
  priority_encoder_if priority_encoder_if_inst(clk, rst);

  // DUT instantiation
  top_module dut (
    .in(priority_encoder_if_inst.in),
    .clk(clk),
    .reset(rst),
    .pos(priority_encoder_if_inst.pos)
  );
  
  // TODO: Connect the generated clock, reset to all the required interfaces

   initial begin
      
      // TODO: Replace '<Interface instance for priority_encoder_if>' with the actual interface instance name for priority_encoder_if
      uvm_config_db #(vif_priority_encoder_if)::set(null,"","priority_encoder_agent_priority_encoder_if", priority_encoder_if_inst); 

      run_test();
   end

   // Do not add any stimulus here it will be taken care of in the UVM driver

   // Do not edit the below code
   initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, priority_encoder_tb_top);
   end    

endmodule: priority_encoder_tb_top

`endif // PRIORITY_ENCODER_ENV_TB_MOD__SV