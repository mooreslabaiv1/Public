


module weighted_round_robin_tb_top;

  import uvm_pkg::*;
  import weighted_round_robin_test_pkg::*;

  // Interface instances
  clk_rst_if     clk_rst_if_inst();
  rr_request_if  rr_request_if_inst(.clk(clk_rst_if_inst.clk), .rst(clk_rst_if_inst.rst));
  rr_grant_if    rr_grant_if_inst(.clk(clk_rst_if_inst.clk), .rst(clk_rst_if_inst.rst));
  prio_update_if prio_update_if_inst(.clk(clk_rst_if_inst.clk), .rst(clk_rst_if_inst.rst));

  // DUT instantiation - match RTL port names
  weighted_round_robin weighted_round_robin_inst (
    .clk     (clk_rst_if_inst.clk),
    .rst     (clk_rst_if_inst.rst),
    .req     (rr_request_if_inst.req),
    .ack     (rr_request_if_inst.ack),
    .gnt_w   (rr_grant_if_inst.gnt_w),
    .gnt_id  (rr_grant_if_inst.gnt_id),
    .prio    (prio_update_if_inst.prio),
    .prio_id (prio_update_if_inst.prio_id),
    .prio_upt(prio_update_if_inst.prio_upt)
  );

  // Hook up virtual interfaces and start UVM
  initial begin
    uvm_config_db#(virtual clk_rst_if    )::set(null, "*", "clk_rst_if",              clk_rst_if_inst);
    uvm_config_db#(virtual rr_request_if )::set(null, "*", "rr_request_if",           rr_request_if_inst);
    uvm_config_db#(virtual rr_grant_if   )::set(null, "*", "rr_grant_monitor_if",     rr_grant_if_inst);
    uvm_config_db#(virtual prio_update_if)::set(null, "*", "prio_update_if",          prio_update_if_inst);

    // Start UVM. You can override via +UVM_TESTNAME=...
    run_test();
  end

  // ToDo: Do not edit the below code
  initial begin
    string testname;

    if (!$value$plusargs("UVM_TESTNAME=%s", testname)) begin
      testname = "default";
    end

    $dumpfile($sformatf("testbench_%s.vcd", testname));
    $dumpvars(0, weighted_round_robin_tb_top);
  end

endmodule
