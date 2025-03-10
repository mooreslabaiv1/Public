



`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_DRIVER__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_DRIVER__SV

typedef class priority_encoder_priority_encoder_agent_base_transaction;
typedef class priority_encoder_priority_encoder_driver;


class priority_encoder_priority_encoder_driver extends uvm_driver # (priority_encoder_priority_encoder_agent_base_transaction);

   
   typedef virtual priority_encoder_if v_if; 
   v_if drv_if;
   
   extern function new(string name = "priority_encoder_priority_encoder_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(priority_encoder_priority_encoder_driver)
      `uvm_component_utils_end

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(priority_encoder_priority_encoder_agent_base_transaction tr); 
   extern protected virtual task tx_driver();

endclass: priority_encoder_priority_encoder_driver


function priority_encoder_priority_encoder_driver::new(string name = "priority_encoder_priority_encoder_driver",
                   uvm_component parent = null);
   super.new(name, parent);
endfunction: new


function void priority_encoder_priority_encoder_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction: build_phase

function void priority_encoder_priority_encoder_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "priority_encoder_agent_priority_encoder_if", drv_if);
endfunction: connect_phase

function void priority_encoder_priority_encoder_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void priority_encoder_priority_encoder_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase

 
task priority_encoder_priority_encoder_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask: reset_phase

task priority_encoder_priority_encoder_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase


task priority_encoder_priority_encoder_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork 
      tx_driver();
   join
endtask: run_phase


task priority_encoder_priority_encoder_driver::tx_driver();
   priority_encoder_priority_encoder_agent_base_transaction tr;
   begin
      while (drv_if.rst) @(posedge drv_if.clk);
      repeat(1) @(posedge drv_if.clk);

      forever begin
         seq_item_port.get_next_item(tr);
         send(tr);
         seq_item_port.item_done();
      end
   end
endtask : tx_driver

task priority_encoder_priority_encoder_driver::send(priority_encoder_priority_encoder_agent_base_transaction tr);
   single_input_test_seq_item single_tr;  // For single-bit sequences
   multiple_inputs_test_seq_item multi_tr; // For multiple-bit sequences

   if ($cast(single_tr, tr)) begin
      // Handle single-input test sequence
      drv_if.in = single_tr.in_data; // Drive the single-bit randomized input
      `uvm_info("DRIVER", $sformatf("Driving single_input_test_seq_item: in_data = %b at time = %0t", single_tr.in_data, $time), UVM_LOW);
   end else if ($cast(multi_tr, tr)) begin
      // Handle multiple-input test sequence
      drv_if.in = multi_tr.in_data; // Drive the multi-bit randomized input
      `uvm_info("DRIVER", $sformatf("Driving multiple_inputs_test_seq_item: in_data = %b at time = %0t", multi_tr.in_data, $time), UVM_LOW);
   end else begin
      drv_if.in = tr.sa[3:0];
   end

   @(posedge drv_if.clk); // Wait for clock edge
endtask



`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_DRIVER__SV