+libext+.v+.sv
+incdir+../env+../scoreboard+../sequences+../agents+../tests+../top
+incdir+../agents/wrr_arbitration_agent
+incdir+../agents/wrr_arbitration_agent/seq_lib
+incdir+../agents/wrr_prio_update_agent
+incdir+../agents/wrr_prio_update_agent/seq_lib
+incdir+../agents/clk_rst_agent
+incdir+../agents/clk_rst_agent/seq_lib

// Interfaces
../agents/wrr_arbitration_agent/wrr_arbitration_if.sv
../agents/wrr_prio_update_agent/wrr_prio_update_if.sv
../agents/clk_rst_agent/clk_rst_if.sv

// Agents
../agents/wrr_arbitration_agent/wrr_arbitration_agent_pkg.sv
../agents/wrr_prio_update_agent/wrr_prio_update_agent_pkg.sv
../agents/clk_rst_agent/clk_rst_agent_pkg.sv

// Environment
../env/weighted_round_robin_env_pkg.sv

// Sequences
../agents/wrr_arbitration_agent/seq_lib/wrr_arbitration_seq_pkg.sv
../agents/wrr_prio_update_agent/seq_lib/wrr_prio_update_seq_pkg.sv
../agents/clk_rst_agent/seq_lib/clk_rst_seq_pkg.sv

// Tests
../tests/weighted_round_robin_test_pkg.sv


// Top TB
../top/weighted_round_robin_tb_top.sv
