


`ifndef FSM_SEEK_DETECT_ENV_TB_MOD__SV
`define FSM_SEEK_DETECT_ENV_TB_MOD__SV
`include "interfaces.incl"
module fsm_seek_detect_tb_top;

import uvm_pkg::*;

`include "fsm_seek_detect_env.sv"
`include "fsm_seek_detect_env_test.sv"
`include "asyncresettest_test.sv"
`include "basicfunctionalitytest_test.sv"
// <Optional> ToDo: Include all other test list here
`include "overlappingsequencetest_test.sv"
   
   typedef virtual fsm_seek_detect_if vif_fsm_seek_detect_if;


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
    rst = 0;
    #10 rst = 1;
  end

  // Optional: If you need to generate clocks, resets in a different domain do it below  

  // TODO: Do the DUT instantiation below
  fsm_seek_detect dut (
    .clk(clk),
    .aresetn(rst),
    .x(fsm_seek_detect_if_inst.x),
    .z(fsm_seek_detect_if_inst.z)
  );
  
  // TODO: Connect the generated clock, reset to all the required interfaces
  fsm_seek_detect_if fsm_seek_detect_if_inst (.clk(clk), .aresetn(rst));

   initial begin
      
      // TODO: Replace '<Interface instance for fsm_seek_detect_if>' with the actual interface instance name for fsm_seek_detect_if
      uvm_config_db #(vif_fsm_seek_detect_if)::set(null,"","fsm_seek_detect_agent_fsm_seek_detect_if", fsm_seek_detect_if_inst); 

      run_test();
   end

   // Do not add any stimulus here it will be taken care of in the UVM driver

   // Do not edit the below code
   initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, fsm_seek_detect_tb_top);
   end    

endmodule: fsm_seek_detect_tb_top

`endif // FSM_SEEK_DETECT_ENV_TB_MOD__SV