




`ifndef FSM_ONE_HOT_ENV_TB_MOD__SV
`define FSM_ONE_HOT_ENV_TB_MOD__SV
`include "interfaces.incl"

import uvm_pkg::*;

// Include the RTL module definition to avoid unresolved module errors

`include "fsm_one_hot_env.sv"
`include "fsm_one_hot_env_test.sv"

`include "sequence_detection_-_1101_test.sv"
`include "counting_operation_post_sequence_detection_test.sv"
`include "full_fsm_traversal_test.sv"
// `include "invalid_state_recovery_mechanism_test.sv"
// `include "fsm_one_hot_reset_functionality_check_test.sv"

module fsm_one_hot_tb_top;

   typedef virtual fsm_if vif_fsm_if;

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

   fsm_one_hot dut (
     .clk(clk),
     .rst(rst),
     .d(fsm_if_inst.d),
     .done_counting(fsm_if_inst.done_counting),
     .ack(fsm_if_inst.ack),
     .done(fsm_if_inst.done),
     .counting(fsm_if_inst.counting),
     .shift_ena(fsm_if_inst.shift_ena)
   );

   fsm_if fsm_if_inst (
     .clk(clk),
     .rst(rst)
   );

   initial begin
     uvm_config_db #(vif_fsm_if)::set(null,"","fsm_agent_fsm_if", fsm_if_inst); 
     run_test();
   end

   initial begin
     $dumpfile("testbench.vcd");
     $dumpvars(0, fsm_one_hot_tb_top);
   end    

endmodule: fsm_one_hot_tb_top

`endif // FSM_ONE_HOT_ENV_TB_MOD__SV