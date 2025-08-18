`ifndef SERIAL_IP_ENV_TB_MOD__SV
`define SERIAL_IP_ENV_TB_MOD__SV

module serial_ip_tb_top;

  import uvm_pkg::*;
  import serial_ip_env_pkg::*;

  // Clock and reset signals - Do not remove
  logic clk;
  logic rst;

  // Interface instantiations
  clk_rst_if clk_rst_if_inst ();
  assign clk = clk_rst_if_inst.clk;
  assign rst = clk_rst_if_inst.rst;
  serial_if serial_if_inst( .clk(clk), .rst(rst) );

  // TODO: Do the DUT instantiation below
  serialDP u_serialDP (
    .clk      (clk),
    .in       (serial_if_inst.in),
    .reset    (rst),
    .out_byte (serial_if_inst.out_byte),
    .done     (serial_if_inst.done)
  );

  initial begin
    uvm_config_db#(virtual serial_if)::set(null, "", "serial_if", serial_if_inst);
    uvm_config_db#(virtual clk_rst_if)::set(null, "", "clk_rst_if", clk_rst_if_inst);
    run_test();
  end

  // ToDo: Do not edit the below code
  initial begin
    string testname;

    if (!$value$plusargs("UVM_TESTNAME=%s", testname)) begin
      testname = "default";
    end

    $dumpfile($sformatf("testbench_%s.vcd", testname));
    $dumpvars(0, serial_ip_tb_top);
  end

endmodule : serial_ip_tb_top
`endif