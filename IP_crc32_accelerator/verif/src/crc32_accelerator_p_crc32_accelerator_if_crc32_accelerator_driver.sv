

`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_DRIVER__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_DRIVER__SV

class crc32_accelerator_p_crc32_accelerator_driver extends uvm_driver # (crc32_accelerator_p_crc32_accelerator_agent_base_transaction);

  typedef virtual crc32_accelerator_if v_if; 
  v_if drv_if;

  uvm_analysis_port #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction) driver_analysis_port;

  extern function new(string name = "crc32_accelerator_p_crc32_accelerator_driver",
                      uvm_component parent = null); 

  `uvm_component_utils_begin(crc32_accelerator_p_crc32_accelerator_driver)
  `uvm_component_utils_end

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task send(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr); 
  extern protected virtual task tx_driver();

endclass: crc32_accelerator_p_crc32_accelerator_driver

function crc32_accelerator_p_crc32_accelerator_driver::new(string name = "crc32_accelerator_p_crc32_accelerator_driver",
                       uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void crc32_accelerator_p_crc32_accelerator_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(v_if)::get(this, "", "vif", drv_if)) begin
    `uvm_fatal("DRV/NOVIF", "No virtual interface specified for driver")
  end
  driver_analysis_port = new("driver_analysis_port", this);
endfunction: build_phase

function void crc32_accelerator_p_crc32_accelerator_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

function void crc32_accelerator_p_crc32_accelerator_driver::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  if (drv_if == null)
      `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void crc32_accelerator_p_crc32_accelerator_driver::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

task crc32_accelerator_p_crc32_accelerator_driver::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask: reset_phase

task crc32_accelerator_p_crc32_accelerator_driver::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask: configure_phase

task crc32_accelerator_p_crc32_accelerator_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork 
     tx_driver();
  join
endtask: run_phase

task crc32_accelerator_p_crc32_accelerator_driver::tx_driver();
  crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr;

  wait (drv_if.rst == 0);
  repeat (3) @(posedge drv_if.clk);

  forever begin
    `uvm_info("crc32_accelerator_p_env_DRIVER", "Starting transaction...",UVM_LOW)
    seq_item_port.get_next_item(tr);
    send(tr); 
    seq_item_port.item_done();
    `uvm_info("crc32_accelerator_p_env_DRIVER", "Completed transaction...",UVM_LOW)
    `uvm_info("crc32_accelerator_p_env_DRIVER", tr.sprint(),UVM_HIGH)
  end
endtask : tx_driver

task crc32_accelerator_p_crc32_accelerator_driver::send(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr);
  logic [7:0] data_in_local;
  logic       data_valid_local;

  data_in_local = tr.data_in;
  data_valid_local = tr.data_valid;

  drv_if.drv_cb.data_in <= data_in_local;
  drv_if.drv_cb.data_valid <= data_valid_local && ~drv_if.rst;

  $display("Inside driver");

  driver_analysis_port.write(tr);  // Write the transaction to the analysis port

  @(posedge drv_if.clk);

  drv_if.drv_cb.data_valid <= 0;
endtask: send

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_DRIVER__SV