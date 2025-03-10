


`ifndef CRC32_ACCELERATOR_P_ENV__SV
`define CRC32_ACCELERATOR_P_ENV__SV
`include "crc32_accelerator_p_env_inc.sv"

class crc32_accelerator_p_env extends uvm_env;
   crc32_accelerator_p_sbd sb;
   
   crc32_accelerator_p_crc32_accelerator_agent crc32_accelerator_agent;

   crc32_accelerator_p_crc32_accelerator_monitor_env_cov cov_crc32_accelerator_p_crc32_accelerator_monitor;

   crc32_accelerator_p_crc32_accelerator_monitor_connect_cov mon2cov_crc32_accelerator_p_crc32_accelerator_monitor;

    `uvm_component_utils(crc32_accelerator_p_env)

   extern function new(string name="crc32_accelerator_p_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: crc32_accelerator_p_env

function crc32_accelerator_p_env::new(string name= "crc32_accelerator_p_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void crc32_accelerator_p_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   crc32_accelerator_agent = crc32_accelerator_p_crc32_accelerator_agent::type_id::create("crc32_accelerator_agent",this);

   cov_crc32_accelerator_p_crc32_accelerator_monitor = crc32_accelerator_p_crc32_accelerator_monitor_env_cov::type_id::create("cov_crc32_accelerator_p_crc32_accelerator_monitor",this); //Instantiating the coverage class

   mon2cov_crc32_accelerator_p_crc32_accelerator_monitor  = crc32_accelerator_p_crc32_accelerator_monitor_connect_cov::type_id::create("mon2cov_crc32_accelerator_p_crc32_accelerator_monitor", this);
   mon2cov_crc32_accelerator_p_crc32_accelerator_monitor.cov = cov_crc32_accelerator_p_crc32_accelerator_monitor;

   sb = crc32_accelerator_p_sbd::type_id::create("sb",this);

endfunction: build_phase

function void crc32_accelerator_p_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

   // Connect driver analysis port to scoreboard input fifo
   crc32_accelerator_agent.drv.driver_analysis_port.connect(sb.in_fifo.analysis_export);

   // Connect monitor analysis port to scoreboard output fifo
   crc32_accelerator_agent.mon.mon_analysis_port.connect(sb.out_fifo.analysis_export);

   // Other connections
   crc32_accelerator_agent.mon.mon_analysis_port.connect(cov_crc32_accelerator_p_crc32_accelerator_monitor.cov_export);

endfunction: connect_phase

function void crc32_accelerator_p_env::start_of_simulation_phase(uvm_phase phase);
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

task crc32_accelerator_p_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask:reset_phase

task crc32_accelerator_p_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task crc32_accelerator_p_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
endtask:run_phase

function void crc32_accelerator_p_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
endfunction:report_phase

task crc32_accelerator_p_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // CRC32_ACCELERATOR_P_ENV__SV