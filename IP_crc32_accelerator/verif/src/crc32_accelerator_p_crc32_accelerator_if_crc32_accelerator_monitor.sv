

`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR__SV

import uvm_pkg::*; 

class crc32_accelerator_p_crc32_accelerator_monitor extends uvm_monitor;

  uvm_analysis_port #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction) mon_analysis_port;  //TLM analysis port
  typedef virtual crc32_accelerator_if v_if;
  v_if mon_if;

  extern function new(string name = "crc32_accelerator_p_crc32_accelerator_monitor",uvm_component parent);
  `uvm_component_utils_begin(crc32_accelerator_p_crc32_accelerator_monitor)
  `uvm_component_utils_end

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task tx_monitor();

endclass: crc32_accelerator_p_crc32_accelerator_monitor

function crc32_accelerator_p_crc32_accelerator_monitor::new(string name = "crc32_accelerator_p_crc32_accelerator_monitor",uvm_component parent);
  super.new(name, parent);
  mon_analysis_port = new ("mon_analysis_port",this);
endfunction: new

function void crc32_accelerator_p_crc32_accelerator_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(v_if)::get(this, "", "vif", mon_if)) begin
    `uvm_fatal("MON/NOVIF", "No virtual interface specified for monitor")
  end
endfunction: build_phase

function void crc32_accelerator_p_crc32_accelerator_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

function void crc32_accelerator_p_crc32_accelerator_monitor::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase); 
endfunction: end_of_elaboration_phase

function void crc32_accelerator_p_crc32_accelerator_monitor::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

task crc32_accelerator_p_crc32_accelerator_monitor::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask: reset_phase

task crc32_accelerator_p_crc32_accelerator_monitor::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask: configure_phase

task crc32_accelerator_p_crc32_accelerator_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
    tx_monitor();
  join
endtask: run_phase

task crc32_accelerator_p_crc32_accelerator_monitor::tx_monitor();
  crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;

  wait (mon_if.rst == 0);

  forever begin
    @(posedge mon_if.clk);


    `uvm_info("CRC_SBD", $sformatf("crc_mon data_in = 0x%h, data_valid = 0x%h \n ",
                               mon_if.data_in, mon_if.data_valid), UVM_LOW);

      tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("tr", this);

      tr.data_in = mon_if.data_in;
      tr.data_valid = mon_if.data_valid;
      tr.crc_out = mon_if.crc_out;
      tr.crc_valid = mon_if.crc_valid;

      `uvm_info("crc32_accelerator_p_env_MONITOR", "Captured transaction...", UVM_LOW)
      `uvm_info("crc32_accelerator_p_env_MONITOR", tr.sprint(), UVM_LOW)
      mon_analysis_port.write(tr);

  end
endtask: tx_monitor

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_MONITOR__SV