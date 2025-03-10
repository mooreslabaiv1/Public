`ifndef FSM_ONE_HOT_ENV__SV
`define FSM_ONE_HOT_ENV__SV
`include "fsm_one_hot_env_inc.sv"
`include "fsm_one_hot_sbd.sv"

class fsm_one_hot_env extends uvm_env;
   fsm_one_hot_sbd sb;
   
   fsm_one_hot_fsm_agent fsm_agent;

   
   fsm_one_hot_fsm_monitor_env_cov cov_fsm_one_hot_fsm_monitor;


   
   fsm_one_hot_fsm_monitor_connect_cov mon2cov_fsm_one_hot_fsm_monitor;


    `uvm_component_utils(fsm_one_hot_env)

   extern function new(string name="fsm_one_hot_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: fsm_one_hot_env

function fsm_one_hot_env::new(string name= "fsm_one_hot_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void fsm_one_hot_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   fsm_agent = fsm_one_hot_fsm_agent::type_id::create("fsm_agent",this);
 
   cov_fsm_one_hot_fsm_monitor = fsm_one_hot_fsm_monitor_env_cov::type_id::create("cov_fsm_one_hot_fsm_monitor",this); //Instantiating the coverage class

   mon2cov_fsm_one_hot_fsm_monitor  = fsm_one_hot_fsm_monitor_connect_cov::type_id::create("mon2cov_fsm_one_hot_fsm_monitor", this);
   mon2cov_fsm_one_hot_fsm_monitor.cov = cov_fsm_one_hot_fsm_monitor;

   sb = fsm_one_hot_sbd::type_id::create("sb",this);
endfunction: build_phase

function void fsm_one_hot_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   fsm_agent.mon.mon_analysis_port.connect(sb.fsm_one_hot_fsm_agent_fifo.analysis_export);
   fsm_agent.mon.mon_analysis_port.connect(cov_fsm_one_hot_fsm_monitor.cov_export);

   // Pass the agent's interface to the scoreboard
   uvm_config_db#(fsm_one_hot_fsm_agent::vif_fsm_if)::set(this, "sb","fsm_agent_fsm_if", fsm_agent.get_fsm_if());
endfunction: connect_phase

function void fsm_one_hot_env::start_of_simulation_phase(uvm_phase phase);
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


task fsm_one_hot_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask:reset_phase

task fsm_one_hot_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task fsm_one_hot_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
endtask:run_phase

function void fsm_one_hot_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
endfunction:report_phase

task fsm_one_hot_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // FSM_ONE_HOT_ENV__SV