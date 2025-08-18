

`ifndef SERIAL_IP_SCOREBOARD__SV
`define SERIAL_IP_SCOREBOARD__SV

// -----------------------------------------------------
// Reference Model Definition
// -----------------------------------------------------
typedef enum logic [2:0] { 
  RM_IDLE, 
  RM_START, 
  RM_SHIFT, 
  RM_PARITY, 
  RM_STOP, 
  RM_DONE 
} rm_state_t;

class serial_ref_model extends uvm_component;

  // Internal reference model state
  rm_state_t   rm_state;
  bit [7:0]    shift_reg;
  int          bit_count;
  bit          parity_val;

  // Factory registration
  `uvm_component_utils(serial_ref_model)

  // Constructor
  function new(string name = "serial_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_model();
  endfunction : build_phase

  // reset the model
  function void reset_model();
    rm_state   = RM_IDLE;
    shift_reg  = '0;
    bit_count  = 0;
    parity_val = 0;
  endfunction : reset_model

  // This function updates model state and returns "ref_done" and "ref_out_byte"
  // after processing the new bit input "rx_in"
  function void rx_in(bit rx_in, ref bit ref_done, ref byte ref_out_byte);
    ref_done      = 0;
    ref_out_byte  = 8'h00;

    case (rm_state)

      RM_IDLE: begin
        // Wait for start bit = 0
        if (rx_in == 0) begin
          rm_state   = RM_START;
        end
      end

      RM_START: begin
        // Already saw start bit. Move to SHIFT for 8 bits
        rm_state   = RM_SHIFT;
        bit_count  = 0;
        shift_reg  = '0;
        parity_val = 0;
      end

      RM_SHIFT: begin
        // Shift in data bits
        shift_reg  = {rx_in, shift_reg[7:1]};
        parity_val = parity_val ^ rx_in;
        bit_count++;
        if (bit_count == 8) begin
          rm_state = RM_PARITY;
        end
      end

      RM_PARITY: begin
        // Collect parity bit
        bit parity_bit;
        parity_bit = rx_in;
        parity_val = parity_val ^ parity_bit;
        // Check if final parity_val is 1 for ODD parity
        if (parity_val == 1) begin
          rm_state = RM_STOP;
        end
        else begin
          // Parity error -> discard data, go to IDLE
          rm_state = RM_IDLE;
        end
      end

      RM_STOP: begin
        // Expect stop bit = 1
        if (rx_in == 1) begin
          rm_state     = RM_DONE;
        end
        else begin
          // Stop bit error -> discard data, go to IDLE
          rm_state     = RM_IDLE;
        end
      end

      RM_DONE: begin
        // We have a valid byte
        ref_done      = 1;
        ref_out_byte  = shift_reg;
        // Go back to IDLE
        rm_state      = RM_IDLE;
      end

      default: rm_state = RM_IDLE;

    endcase
  endfunction : rx_in

endclass : serial_ref_model

// -----------------------------------------------------
// Scoreboard
// -----------------------------------------------------
class serial_ip_scoreboard extends uvm_scoreboard;

  // TLM Fifo (analysis port)
  uvm_tlm_analysis_fifo #(serial_trans_item) serial_ip_serial_agent_fifo;
  uvm_tlm_analysis_fifo #(clk_rst_trans_item) serial_ip_clk_rst_agent_fifo;

  // Reference model instance
  serial_ref_model ref_model;

  // Register with factory
  `uvm_component_utils(serial_ip_scoreboard)

  //******************************************************************************
  // Constructor
  //******************************************************************************
  function new(string name = "serial_ip_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //*****************************************************************************
  // Build Phase
  //*****************************************************************************
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    serial_ip_serial_agent_fifo    = new("serial_ip_serial_agent_fifo", this);
    serial_ip_clk_rst_agent_fifo   = new("serial_ip_clk_rst_agent_fifo", this);

    // Create reference model
    ref_model = serial_ref_model::type_id::create("ref_model", this);

  endfunction : build_phase

  //******************************************************************************
  // Connect Phase
  //******************************************************************************
  function void connect_phase(uvm_phase phase);
  endfunction : connect_phase

  //******************************************************************************
  // Run Phase
  //******************************************************************************  
  task run_phase(uvm_phase phase);
    fork
      process_serial_agent_fifo();
      process_clk_rst_agent_fifo();
    join_none
  endtask : run_phase

  //*******************************************************************************
  // Helper Tasks
  //*******************************************************************************  

  task process_serial_agent_fifo();
    serial_trans_item tr;
    bit ref_done;
    byte ref_out_byte;

    forever begin
      serial_ip_serial_agent_fifo.get(tr);
      `uvm_info(get_full_name(), $sformatf("RECEIVED TRANSACTION\n%s", tr.sprint()), UVM_HIGH)

      // Pass inputs to reference model
      ref_model.rx_in(tr.in, ref_done, ref_out_byte);

      // Compare reference model outputs with DUT outputs:
      if (ref_done !== tr.done) begin
        `uvm_error(get_full_name(), $sformatf("Mismatch in 'done' signal! REF=%0b, DUT=%0b", ref_done, tr.done))
      end
      if ((ref_done == 1) && (ref_out_byte !== tr.out_byte)) begin
        `uvm_error(get_full_name(), $sformatf("Mismatch in 'out_byte'! REF=0x%02h, DUT=0x%02h", ref_out_byte, tr.out_byte))
      end
    end
  endtask : process_serial_agent_fifo

  task process_clk_rst_agent_fifo();
    clk_rst_trans_item tr;
    forever begin
      serial_ip_clk_rst_agent_fifo.get(tr);
      `uvm_info(get_full_name(), $sformatf("RESET TRANSACTION\n%s", tr.sprint()), UVM_LOW)
      // Reset on scoreboard side
      if (tr.reset_asserted || tr.reset_deasserted) begin
        serial_ip_serial_agent_fifo.flush();
        serial_ip_clk_rst_agent_fifo.flush();
        ref_model.reset_model();
      end
    end
  endtask : process_clk_rst_agent_fifo

endclass : serial_ip_scoreboard
`endif  // SERIAL_IP_SCOREBOARD__SV