+libext+.v+.sv
+incdir+../env+../scoreboard+../sequences+../agents+../tests+../top
+incdir+../agents/requestor_agent
+incdir+../agents/requestor_agent/seq_lib
+incdir+../agents/prio_update_agent
+incdir+../agents/prio_update_agent/seq_lib
+incdir+../agents/clk_rst_agent
+incdir+../agents/clk_rst_agent/seq_lib

# Interfaces
../agents/requestor_agent/requestor_if.sv
../agents/prio_update_agent/prio_update_if.sv
../agents/clk_rst_agent/clk_rst_if.sv

# Agents
../agents/requestor_agent/requestor_agent_pkg.sv
../agents/prio_update_agent/prio_update_agent_pkg.sv
../agents/clk_rst_agent/clk_rst_agent_pkg.sv

# Environment
../env/weighted_round_robin_env_pkg.sv

# Sequences
../agents/requestor_agent/seq_lib/requestor_seq_pkg.sv
../agents/prio_update_agent/seq_lib/prio_update_seq_pkg.sv
../agents/clk_rst_agent/seq_lib/clk_rst_seq_pkg.sv

# Tests
../tests/weighted_round_robin_test_pkg.sv

