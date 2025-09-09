+libext+.v+.sv
+incdir+../env+../scoreboard+../sequences+../agents+../tests+../top
+incdir+../agents/rr_agent
+incdir+../agents/rr_agent/seq_lib
+incdir+../agents/prio_update_agent
+incdir+../agents/prio_update_agent/seq_lib
+incdir+../agents/clk_rst_agent
+incdir+../agents/clk_rst_agent/seq_lib

// Interfaces
../agents/rr_agent/rr_if.sv
../agents/prio_update_agent/prio_if.sv
../agents/clk_rst_agent/clk_rst_if.sv

// Agents
../agents/rr_agent/rr_agent_pkg.sv
../agents/prio_update_agent/prio_update_agent_pkg.sv
../agents/clk_rst_agent/clk_rst_agent_pkg.sv

// Environment
../env/weighted_round_robin_env_pkg.sv

// Sequences
../agents/rr_agent/seq_lib/rr_seq_pkg.sv
../agents/prio_update_agent/seq_lib/prio_update_seq_pkg.sv
../agents/clk_rst_agent/seq_lib/clk_rst_seq_pkg.sv

// Tests
../tests/weighted_round_robin_test_pkg.sv


// Top TB
../top/weighted_round_robin_tb_top.sv
