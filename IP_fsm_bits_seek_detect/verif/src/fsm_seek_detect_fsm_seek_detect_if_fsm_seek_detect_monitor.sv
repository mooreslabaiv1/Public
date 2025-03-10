



`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR__SV

import uvm_pkg::*; 

typedef class fsm_seek_detect_fsm_seek_detect_agent_base_transaction;
typedef class fsm_seek_detect_fsm_seek_detect_monitor; 

class fsm_seek_detect_fsm_seek_detect_monitor extends uvm_monitor;

   uvm_analysis_port #(fsm_seek_detect_fsm_seek_detect_agent_base_transaction) mon_analysis_port;
   typedef virtual fsm_seek_detect_if v_if;
   v_if mon_if;

   extern function new(string name = "fsm_seek_detect_fsm_seek_detect_monitor",uvm_component parent);
   `uvm_component_utils_begin(fsm_seek_detect_fsm_seek_detect_monitor)
   `uvm_component_utils_end

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task tx_monitor();

endclass: fsm_seek_detect_fsm_seek_detect_monitor


function fsm_seek_detect_fsm_seek_detect_monitor::new(string name = "fsm_seek_detect_fsm_seek_detect_monitor",uvm_component parent);
   super.new(name, parent);
   mon_analysis_port = new ("mon_analysis_port",this);
endfunction: new

function void fsm_seek_detect_fsm_seek_detect_monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction: build_phase

function void fsm_seek_detect_fsm_seek_detect_monitor::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "fsm_seek_detect_agent_fsm_seek_detect_if", mon_if);
endfunction: connect_phase

function void fsm_seek_detect_fsm_seek_detect_monitor::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase

function void fsm_seek_detect_fsm_seek_detect_monitor::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

task fsm_seek_detect_fsm_seek_detect_monitor::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask: reset_phase

task fsm_seek_detect_fsm_seek_detect_monitor::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task fsm_seek_detect_fsm_seek_detect_monitor::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork
      tx_monitor();
   join
endtask: run_phase

task fsm_seek_detect_fsm_seek_detect_monitor::tx_monitor();
   fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr;
   wait(mon_if.aresetn == 1);
   forever begin
      @ (posedge mon_if.clk);
      tr = new("mon_tr");
      tr.x = mon_if.x;
      tr.z = mon_if.z;
      mon_analysis_port.write(tr);
   end
endtask: tx_monitor

`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_MONITOR__SV