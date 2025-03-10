`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR__SV

import uvm_pkg::*; 

typedef class priority_encoder_priority_encoder_agent_base_transaction;
typedef class priority_encoder_priority_encoder_monitor; 

class priority_encoder_priority_encoder_monitor extends uvm_monitor;

   uvm_analysis_port #(priority_encoder_priority_encoder_agent_base_transaction) mon_analysis_port;  //TLM analysis port
   typedef virtual priority_encoder_if v_if;
   v_if mon_if;

   function new(string name = "priority_encoder_priority_encoder_monitor",uvm_component parent);
      super.new(name, parent);
      mon_analysis_port = new ("mon_analysis_port",this);
   endfunction: new

   `uvm_component_utils_begin(priority_encoder_priority_encoder_monitor)
   `uvm_component_utils_end

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      uvm_config_db#(v_if)::get(this, "", "priority_encoder_agent_priority_encoder_if", mon_if);
   endfunction: connect_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase); 
   endfunction: end_of_elaboration_phase

   virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
   endfunction: start_of_simulation_phase

   virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
   endtask: reset_phase

   virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
   endtask:configure_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         tx_monitor();
      join
   endtask: run_phase

protected virtual task tx_monitor();
    priority_encoder_priority_encoder_agent_base_transaction tr;
    logic [3:0] prev_in;    // To store the previous clock's in value
    logic prev_reset;       // To store the previous clock's reset value

    begin
        while (mon_if.rst) @(posedge mon_if.clk); // Wait for reset to deassert

        // Initialize prev_in and prev_reset with the first clock values
        prev_in    = mon_if.in;
        prev_reset = mon_if.rst;

        forever begin
            @(posedge mon_if.clk); // Wait for the next clock edge

            tr = new("mon_tr");

            tr.sa        = prev_in;      // Use the previous clock's in
            tr.reset_val = prev_reset;  // Use the previous clock's reset
            tr.out_pos   = mon_if.pos;  // Use the current clock's pos

            mon_analysis_port.write(tr);

            `uvm_info("MONITOR", $sformatf("Transaction sent: in = %b, reset = %b, pos = %d at time = %0t",
                                           tr.sa, tr.reset_val, tr.out_pos, $time), UVM_LOW);

            prev_in    = mon_if.in;
            prev_reset = mon_if.rst;
        end
    end
endtask: tx_monitor

endclass: priority_encoder_priority_encoder_monitor

`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_MONITOR__SV
