`include "interfaces.incl"

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "weighted_round_robin_env.sv"
`include "weighted_round_robin_env_test.sv"
`include "weighted_round_robin_basic_functionality_test.sv"
`include "weighted_round_robin_bursty_traffic_test.sv"
`include "weighted_round_robin_dynamic_update_test.sv"
`include "weighted_round_robin_extreme_conditions_test.sv"
`include "weighted_round_robin_grant_ack_test.sv"
`include "weighted_round_robin_starvation_risk_test.sv"
`include "weighted_round_robin_weighted_priority_test.sv"
`include "weighted_round_robin_randomized_stress_test.sv"


module weighted_round_robin_tb_top;

  reg clk;
  reg rst;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    #10 rst = 0;
  end

  // Instantiate your interfaces
  requestor_if requestor_if_inst (.*);
  prio_update_if prio_update_if_inst (.*);

  // Instantiate your DUT
  weighted_round_robin #(.N(32), .PRIORITY_W(4)) dut (
    .clk   (clk),
    .rst   (rst),
    .req   (requestor_if_inst.req),
    .ack   (requestor_if_inst.ack),
    .gnt_w (requestor_if_inst.gnt_w),
    .gnt_id(requestor_if_inst.gnt_id),
    .prio  (prio_update_if_inst.prio),
    .prio_id (prio_update_if_inst.prio_id),
    .prio_upt(prio_update_if_inst.prio_upt)
  );

  // Connect clock and reset signals to interfaces
  assign requestor_if_inst.clk = clk;
  assign requestor_if_inst.rst = rst;
  assign prio_update_if_inst.clk = clk;
  assign prio_update_if_inst.rst = rst;

  initial begin
    // Provide the Virtual Interfaces to the agents
    uvm_config_db #(virtual requestor_if)::set(null,"*.requestor_agent*","vif", requestor_if_inst); 
    uvm_config_db #(virtual prio_update_if)::set(null,"*.priority_update_agent*","vif", prio_update_if_inst); 

    // Optionally share the requestor_if with the priority_update_agent if needed
    uvm_config_db #(virtual requestor_if)::set(
      null, "*.priority_update_agent*", "req_vif", requestor_if_inst
    );
  
    // Kick off the UVM run
    run_test();
  end
 
  initial begin
    string vcd_filename;
    if ($value$plusargs("vcdfile=%s", vcd_filename)) begin
      $dumpfile(vcd_filename);
    end else begin
      $dumpfile("default.vcd");
    end
    $dumpvars(0, weighted_round_robin_tb_top);
  end

endmodule: weighted_round_robin_tb_top
