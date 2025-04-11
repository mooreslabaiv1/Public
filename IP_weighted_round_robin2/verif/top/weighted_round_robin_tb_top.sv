`ifndef WEIGHTED_ROUND_ROBIN_ENV_TB_MOD__SV
`define WEIGHTED_ROUND_ROBIN_ENV_TB_MOD__SV

module weighted_round_robin_tb_top;

    import uvm_pkg::*;
    import weighted_round_robin_env_pkg::*;

    // Clock and reset signals - Do not remove
    logic clk;
    logic rst;

    // Interface instantiations
    clk_rst_if clk_rst_if_inst ();
    assign clk = clk_rst_if_inst.clk;
    assign rst = clk_rst_if_inst.rst;
    requestor_if requestor_if_inst (
        .clk(clk),
        .rst(rst)
    );
    prio_update_if prio_update_if_inst (
        .clk(clk),
        .rst(rst)
    );

    // TODO: Do the DUT instantiation below
    weighted_round_robin #(
        .N(32),
        .PRIORITY_W(4),
        .ID_BITS(5),
        .CREDIT_W(8)
    ) u_weighted_round_robin (
        .clk     (clk),
        .rst     (rst),
        .req     (requestor_if_inst.req),
        .ack     (requestor_if_inst.ack),
        .gnt_w   (requestor_if_inst.gnt_w),
        .gnt_id  (requestor_if_inst.gnt_id),
        .prio    (prio_update_if_inst.prio),
        .prio_id (prio_update_if_inst.prio_id),
        .prio_upt(prio_update_if_inst.prio_upt)
    );

    initial begin
        uvm_config_db#(virtual requestor_if)::set(null, "", "requestor_if", requestor_if_inst);
        uvm_config_db#(virtual prio_update_if)::set(null, "", "prio_update_if",
                                                    prio_update_if_inst);
        uvm_config_db#(virtual clk_rst_if)::set(null, "", "clk_rst_if", clk_rst_if_inst);

        run_test();
    end

    // ToDo: Do not edit the below code
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, weighted_round_robin_tb_top);
    end

endmodule : weighted_round_robin_tb_top
`endif
