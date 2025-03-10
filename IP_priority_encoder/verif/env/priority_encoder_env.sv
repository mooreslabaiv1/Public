

`ifndef PRIORITY_ENCODER_ENV__SV
`define PRIORITY_ENCODER_ENV__SV
`include "priority_encoder_env_inc.sv"
//<Optional> ToDo: Include required files here
//Including all the required component files here
class priority_encoder_env extends uvm_env;
   priority_encoder_sbd sb;
   
   priority_encoder_priority_encoder_agent priority_encoder_agent;

   
   priority_encoder_priority_encoder_monitor_env_cov cov_priority_encoder_priority_encoder_monitor;


   
   priority_encoder_priority_encoder_monitor_connect_cov mon2cov_priority_encoder_priority_encoder_monitor;


    `uvm_component_utils(priority_encoder_env)

   extern function new(string name="priority_encoder_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: priority_encoder_env

function priority_encoder_env::new(string name= "priority_encoder_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void priority_encoder_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   priority_encoder_agent = priority_encoder_priority_encoder_agent::type_id::create("priority_encoder_agent",this);
 
   //<Optional> ToDo: Register other components,callbacks and TLM ports if added by user  
   
   cov_priority_encoder_priority_encoder_monitor = priority_encoder_priority_encoder_monitor_env_cov::type_id::create("cov_priority_encoder_priority_encoder_monitor",this); //Instantiating the coverage class

   mon2cov_priority_encoder_priority_encoder_monitor  = priority_encoder_priority_encoder_monitor_connect_cov::type_id::create("mon2cov_priority_encoder_priority_encoder_monitor", this);
   mon2cov_priority_encoder_priority_encoder_monitor.cov = cov_priority_encoder_priority_encoder_monitor;


   sb = priority_encoder_sbd::type_id::create("sb",this);
   // <Optional> ToDo: To enable backdoor access specify the HDL path
   // <Optional> ToDo: Register any required callbacks
endfunction: build_phase

function void priority_encoder_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //Connecting the monitor's analysis ports with priority_encoder_sbd's expected analysis exports.
   
   // Connect monitor analysis port to scoreboard priority_encoder_priority_encoder_agent_fifo
   priority_encoder_agent.mon.mon_analysis_port.connect(sb.priority_encoder_priority_encoder_agent_fifo.analysis_export);


   //Other monitor element will be connected to the after export of the scoreboard
   
   priority_encoder_agent.mon.mon_analysis_port.connect(cov_priority_encoder_priority_encoder_monitor.cov_export);

endfunction: connect_phase

function void priority_encoder_env::start_of_simulation_phase(uvm_phase phase);
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

   // <Optional> ToDo : Implement this phase here 
endfunction: start_of_simulation_phase


task priority_encoder_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   //<Optional> ToDo: Reset DUT
endtask:reset_phase

task priority_encoder_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   //<Optional> ToDo: Configure components here
endtask:configure_phase

task priority_encoder_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
   //<Optional> ToDo: Run your simulation here
endtask:run_phase

function void priority_encoder_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
   //<Optional> ToDo: Implement this phase here
endfunction:report_phase

task priority_encoder_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
   //<Optional> ToDo: Implement this phase here
endtask:shutdown_phase
`endif // PRIORITY_ENCODER_ENV__SV