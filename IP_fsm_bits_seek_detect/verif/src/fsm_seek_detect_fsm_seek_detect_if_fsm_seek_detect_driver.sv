


`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_DRIVER__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_DRIVER__SV

typedef class fsm_seek_detect_fsm_seek_detect_agent_base_transaction;
typedef class fsm_seek_detect_fsm_seek_detect_driver;


class fsm_seek_detect_fsm_seek_detect_driver extends uvm_driver # (fsm_seek_detect_fsm_seek_detect_agent_base_transaction);

   
   typedef virtual fsm_seek_detect_if v_if; 
   v_if drv_if;
   
   extern function new(string name = "fsm_seek_detect_fsm_seek_detect_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(fsm_seek_detect_fsm_seek_detect_driver)
      `uvm_component_utils_end

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr); 
   extern protected virtual task tx_driver();

endclass: fsm_seek_detect_fsm_seek_detect_driver


function fsm_seek_detect_fsm_seek_detect_driver::new(string name = "fsm_seek_detect_fsm_seek_detect_driver",
                   uvm_component parent = null);
   super.new(name, parent);
endfunction: new


function void fsm_seek_detect_fsm_seek_detect_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction: build_phase

function void fsm_seek_detect_fsm_seek_detect_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "fsm_seek_detect_agent_fsm_seek_detect_if", drv_if);
endfunction: connect_phase

function void fsm_seek_detect_fsm_seek_detect_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");
endfunction: end_of_elaboration_phase

function void fsm_seek_detect_fsm_seek_detect_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

 
task fsm_seek_detect_fsm_seek_detect_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask: reset_phase

task fsm_seek_detect_fsm_seek_detect_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase


task fsm_seek_detect_fsm_seek_detect_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork 
      tx_driver();
   join
endtask: run_phase


task fsm_seek_detect_fsm_seek_detect_driver::tx_driver();
   fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr;
   wait(drv_if.aresetn == 1);
   repeat(3) @(posedge drv_if.clk);
   forever begin
      seq_item_port.get_next_item(tr);
      send(tr);
      seq_item_port.item_done();
   end
endtask : tx_driver

task fsm_seek_detect_fsm_seek_detect_driver::send(fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr);
   drv_if.x <= tr.x;
   @(posedge drv_if.clk);
endtask: send


`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_DRIVER__SV