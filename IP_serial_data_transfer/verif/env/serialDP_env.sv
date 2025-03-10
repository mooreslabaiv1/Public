


`ifndef SERIALDP_ENV__SV
`define SERIALDP_ENV__SV
`include "serialDP_env_inc.sv"
//Including all the required component files here
class serialDP_env extends uvm_env;
   serialDP_sbd sb;
   
   serialDP_serial_agent serial_agent;

   
   serialDP_serial_if_monitor_env_cov cov_serialDP_serial_if_monitor;


   
   serialDP_serial_if_monitor_connect_cov mon2cov_serialDP_serial_if_monitor;


    `uvm_component_utils(serialDP_env)

   extern function new(string name="serialDP_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: serialDP_env

function serialDP_env::new(string name= "serialDP_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void serialDP_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   serial_agent = serialDP_serial_agent::type_id::create("serial_agent",this);
 
   
   cov_serialDP_serial_if_monitor = serialDP_serial_if_monitor_env_cov::type_id::create("cov_serialDP_serial_if_monitor",this); //Instantiating the coverage class

   mon2cov_serialDP_serial_if_monitor  = serialDP_serial_if_monitor_connect_cov::type_id::create("mon2cov_serialDP_serial_if_monitor", this);
   mon2cov_serialDP_serial_if_monitor.cov = cov_serialDP_serial_if_monitor;


   sb = serialDP_sbd::type_id::create("sb",this);

endfunction: build_phase

function void serialDP_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //Connecting the monitor's analysis ports with serialDP_sbd's expected analysis exports.
   
   // Connect monitor analysis port to scoreboard serialDP_serial_agent_fifo
   serial_agent.mon.mon_analysis_port.connect(sb.serialDP_serial_agent_fifo.analysis_export);


   //Other monitor element will be connected to the after export of the scoreboard
   
   serial_agent.mon.mon_analysis_port.connect(cov_serialDP_serial_if_monitor.cov_export);

endfunction: connect_phase

function void serialDP_env::start_of_simulation_phase(uvm_phase phase);
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


task serialDP_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask:reset_phase

task serialDP_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task serialDP_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
endtask:run_phase

function void serialDP_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
endfunction:report_phase

task serialDP_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // SERIALDP_ENV__SV