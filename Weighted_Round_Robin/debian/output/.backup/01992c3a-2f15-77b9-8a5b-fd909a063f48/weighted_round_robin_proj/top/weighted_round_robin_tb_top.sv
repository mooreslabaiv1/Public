module weighted_round_robin_tb_top;

  import uvm_pkg::*;
  import weighted_round_robin_test_pkg::*;
  `include "uvm_macros.svh"

  logic clk;
  logic rst;

  clk_rst_if clk_rst_if_inst ();
  assign clk = clk_rst_if_inst.clk;
  assign rst = clk_rst_if_inst.rst;
  rr_if rr_if_inst( .clk(clk), .rst(rst) );
  prio_if prio_if_inst( .clk(clk), .rst(rst) );

  weighted_round_robin #(.N(32), .ID_BITS(5), .PRIORITY_W(4)) dut (
    .clk(clk),
    .rst(rst),
    .req(rr_if_inst.req),
    .ack(rr_if_inst.ack),
    .gnt_w(rr_if_inst.gnt_w),
    .gnt_id(rr_if_inst.gnt_id),
    .prio(prio_if_inst.prio),
    .prio_id(prio_if_inst.prio_id),
    .prio_upt(prio_if_inst.prio_upt)
  );

  initial begin
    uvm_config_db#(virtual rr_if)::set(null, "", "rr_if", rr_if_inst);
    uvm_config_db#(virtual prio_if)::set(null, "", "prio_if", prio_if_inst);
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
