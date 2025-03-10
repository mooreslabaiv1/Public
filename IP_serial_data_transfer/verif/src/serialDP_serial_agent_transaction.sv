`ifndef SERIALDP_SERIAL_AGENT_TRANSACTION__SV
`define SERIALDP_SERIAL_AGENT_TRANSACTION__SV

class serialDP_serial_agent_base_transaction extends uvm_sequence_item;

   // ------------------------------------------------------
   // Existing fields for controlling the driver 
   // ------------------------------------------------------
   typedef enum { READ, WRITE } kinds_e;
   rand kinds_e kind;

   typedef enum { IS_OK, ERROR } status_e;
   rand status_e status;

   // This 'sa' is the 8-bit data to send in a WRITE, or read in a READ
   rand byte sa;

   // ------------------------------------------------------
   // Add new fields to store the *actual* bits from the DUT
   // or from our driver if you want to track them
   // ------------------------------------------------------

   // Full 10-bit frame: start bit (index 0) + 8 data bits + parity bit (index 9)
   rand bit [9:0] full_frame;

   // The stop bit (the 11th bit)
   rand bit       stop_bit;

   // The DUT's final output: 
   //   out_byte => the 8-bit data that the DUT latched
   //   done     => whether the DUT flagged "correct" or not
   rand logic [7:0] out_byte;
   rand bit         done;

   // ------------------------------------------------------
   // UVM Macros for reflection / factory
   // ------------------------------------------------------
   `uvm_object_utils_begin(serialDP_serial_agent_base_transaction)
      `uvm_field_enum(kinds_e,  kind,  UVM_ALL_ON)
      `uvm_field_enum(status_e, status,UVM_ALL_ON)
      `uvm_field_int(sa,                UVM_ALL_ON)
      `uvm_field_int(full_frame,        UVM_ALL_ON)
      `uvm_field_int(stop_bit,          UVM_ALL_ON)
      `uvm_field_int(out_byte,          UVM_ALL_ON)
      `uvm_field_int(done,              UVM_ALL_ON)
   `uvm_object_utils_end

   // ------------------------------------------------------
   // Constructor
   // ------------------------------------------------------
   function new(string name = "Trans");
      super.new(name);
   endfunction: new

endclass: serialDP_serial_agent_base_transaction

`endif // SERIALDP_SERIAL_AGENT_TRANSACTION__SV
