

`ifndef WEIGHTED_ROUND_ROBIN_ENV__SV
`define WEIGHTED_ROUND_ROBIN_ENV__SV
`include "weighted_round_robin_env_inc.sv"
`include "uvm_macros.svh"

class weighted_round_robin_env extends uvm_env;
   weighted_round_robin_sbd sb;
   
   weighted_round_robin_requestor_agent requestor_agent;
   weighted_round_robin_priority_update_agent priority_update_agent;
   
   weighted_round_robin_requestor_monitor_env_cov cov_weighted_round_robin_requestor_monitor;
   weighted_round_robin_prio_update_monitor_env_cov cov_weighted_round_robin_prio_update_monitor;
   
   weighted_round_robin_requestor_monitor_connect_cov mon2cov_weighted_round_robin_requestor_monitor;
   weighted_round_robin_prio_update_monitor_connect_cov mon2cov_weighted_round_robin_prio_update_monitor;

    `uvm_component_utils(weighted_round_robin_env)

   extern function new(string name="weighted_round_robin_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: weighted_round_robin_env

function weighted_round_robin_env::new(string name= "weighted_round_robin_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void weighted_round_robin_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   requestor_agent = weighted_round_robin_requestor_agent::type_id::create("requestor_agent",this);
   priority_update_agent = weighted_round_robin_priority_update_agent::type_id::create("priority_update_agent",this);
   
   cov_weighted_round_robin_requestor_monitor = weighted_round_robin_requestor_monitor_env_cov::type_id::create("cov_weighted_round_robin_requestor_monitor",this);
   mon2cov_weighted_round_robin_requestor_monitor  = weighted_round_robin_requestor_monitor_connect_cov::type_id::create("mon2cov_weighted_round_robin_requestor_monitor", this);
   mon2cov_weighted_round_robin_requestor_monitor.cov = cov_weighted_round_robin_requestor_monitor;

   cov_weighted_round_robin_prio_update_monitor = weighted_round_robin_prio_update_monitor_env_cov::type_id::create("cov_weighted_round_robin_prio_update_monitor",this);
   mon2cov_weighted_round_robin_prio_update_monitor  = weighted_round_robin_prio_update_monitor_connect_cov::type_id::create("mon2cov_weighted_round_robin_prio_update_monitor", this);
   mon2cov_weighted_round_robin_prio_update_monitor.cov = cov_weighted_round_robin_prio_update_monitor;

   sb = weighted_round_robin_sbd::type_id::create("sb",this);
endfunction: build_phase

function void weighted_round_robin_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   
   requestor_agent.mon.mon_analysis_port.connect(sb.requestor_fifo.analysis_export);
   priority_update_agent.mon.mon_analysis_port.connect(sb.priority_update_fifo.analysis_export);
   
   requestor_agent.mon.mon_analysis_port.connect(cov_weighted_round_robin_requestor_monitor.cov_export);
   priority_update_agent.mon.mon_analysis_port.connect(cov_weighted_round_robin_prio_update_monitor.cov_export);
endfunction: connect_phase

function void weighted_round_robin_env::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   `ifdef UVM_VERSION_1_0
   uvm_top.print_topology();  
   factory.print();          
   `endif
   
   `ifdef UVM_VERSION_1_1
	uvm_root::get().print_topology(); 
    uvm_factory::get().print();      
   `endif

   `ifdef UVM_POST_VERSION_1_1
	uvm_root::get().print_topology(); 
    uvm_factory::get().print();      
   `endif
endfunction: start_of_simulation_phase

task weighted_round_robin_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask:reset_phase

task weighted_round_robin_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task weighted_round_robin_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
endtask:run_phase

function void weighted_round_robin_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
endfunction:report_phase

task weighted_round_robin_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // WEIGHTED_ROUND_ROBIN_ENV__SV