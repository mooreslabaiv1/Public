`ifndef SERIALDP_ENV_TB_MOD__SV
`define SERIALDP_ENV_TB_MOD__SV

`include "interfaces.incl"

module serialDP_tb_top;

  import uvm_pkg::*;

  `include "serialDP_env.sv"
  `include "TestCase1_CorrectParity_test.sv"
  `include "TestCase2_IncorrectParity_test.sv"

  `include "serialDP_env_test.sv"

  typedef virtual serial_if vif_serial_if;

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
      rst = 1'b1;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);

      rst = 1'b0;
  end


  // Optional: If you need to generate clocks, resets in a different domain do it below

  // DUT
  serialDP dut (
      .clk      (clk),
      .in       (serial_if_inst.in),
      .reset    (rst),
      .out_byte (serial_if_inst.out_byte),
      .done     (serial_if_inst.done)
  );

  
  serial_if serial_if_inst (.clk(clk), .rst(rst));

  initial begin
      uvm_config_db #(vif_serial_if)::set(null,"","serial_agent_serial_if", serial_if_inst);

      run_test();
  end

  // Do not add any stimulus here it will be taken care of in the UVM driver

  // Do not edit the below code
  initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, serialDP_tb_top);
  end

endmodule: serialDP_tb_top

`endif // SERIALDP_ENV_TB_MOD__SV