`ifndef WEIGHTED_ROUND_ROBIN_ENV_TB_MOD__SV
`define WEIGHTED_ROUND_ROBIN_ENV_TB_MOD__SV
`timescale 1ns/1ns

module weighted_round_robin_tb_top;

  import uvm_pkg::*;
  import weighted_round_robin_test_pkg::*;
  `include "uvm_macros.svh"

  logic clk;
  logic rst;

  clk_rst_if clk_rst_if_inst ();
  assign clk = clk_rst_if_inst.clk;
  assign rst = clk_rst_if_inst.rst;
  wrr_arbitration_if wrr_arbitration_if_inst( .clk(clk), .rst(rst) );
  wrr_prio_update_if wrr_prio_update_if_inst( .clk(clk), .rst(rst) );

  weighted_round_robin #(.N(32), .ID_BITS(5), .PRIORITY_W(4)) dut (
    .clk(clk),
    .rst(rst),
    .req(wrr_arbitration_if_inst.req),
    .ack(wrr_arbitration_if_inst.ack),
    .gnt_w(wrr_arbitration_if_inst.gnt_w),
    .gnt_id(wrr_arbitration_if_inst.gnt_id),
    .prio(wrr_prio_update_if_inst.prio),
    .prio_id(wrr_prio_update_if_inst.prio_id),
    .prio_upt(wrr_prio_update_if_inst.prio_upt)
  );

  initial begin
    uvm_config_db#(virtual wrr_arbitration_if)::set(null, "", "wrr_arbitration_if", wrr_arbitration_if_inst);
    uvm_config_db#(virtual wrr_prio_update_if)::set(null, "", "wrr_prio_update_if", wrr_prio_update_if_inst);
    uvm_config_db#(virtual clk_rst_if)::set(null, "", "clk_rst_if", clk_rst_if_inst);
    run_test();
  end

  initial begin
    $timeformat(-9, 3, "ns");
  end

  initial begin
    string testname;
    if (!$value$plusargs("UVM_TESTNAME=%s", testname)) begin
      testname = "default";
    end
    $dumpfile($sformatf("testbench_%s.vcd", testname));
    $dumpvars(0, weighted_round_robin_tb_top);
  end

endmodule : weighted_round_robin_tb_top
`endif