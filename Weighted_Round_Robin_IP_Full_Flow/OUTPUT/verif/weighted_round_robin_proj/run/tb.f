+libext+.v+.sv
+incdir+../env+../scoreboard+../sequences+../agents+../tests+../top
+incdir+../agents/rr_request_agent
+incdir+../agents/rr_request_agent/seq_lib
+incdir+../agents/rr_grant_monitor_agent
+incdir+../agents/rr_grant_monitor_agent/seq_lib
+incdir+../agents/prio_update_agent
+incdir+../agents/prio_update_agent/seq_lib
+incdir+../agents/clk_rst_agent
+incdir+../agents/clk_rst_agent/seq_lib

# Interfaces
../agents/rr_request_agent/rr_request_if.sv
../agents/rr_grant_monitor_agent/rr_grant_if.sv
../agents/prio_update_agent/prio_update_if.sv
../agents/clk_rst_agent/clk_rst_if.sv

# Agents
../agents/rr_request_agent/rr_request_agent_pkg.sv
../agents/rr_grant_monitor_agent/rr_grant_monitor_agent_pkg.sv
../agents/prio_update_agent/prio_update_agent_pkg.sv
../agents/clk_rst_agent/clk_rst_agent_pkg.sv

# Environment
../env/weighted_round_robin_env_pkg.sv

# Sequences
../agents/rr_request_agent/seq_lib/rr_request_seq_pkg.sv
../agents/rr_grant_monitor_agent/seq_lib/rr_grant_monitor_seq_pkg.sv
../agents/prio_update_agent/seq_lib/prio_update_seq_pkg.sv
../agents/clk_rst_agent/seq_lib/clk_rst_seq_pkg.sv

# Tests
../tests/weighted_round_robin_test_pkg.sv

