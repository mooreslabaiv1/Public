



`ifndef PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_TRANSACTION__SV
`define PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_TRANSACTION__SV


class priority_encoder_priority_encoder_agent_base_transaction extends uvm_sequence_item;

   typedef enum {READ, WRITE } kinds_e;
   rand kinds_e kind;
   typedef enum {IS_OK, ERROR} status_e;
   rand status_e status;
   // In the original code, 'sa' was used to hold input bits; we keep it here as-is:
   rand byte sa;
   // Added fields for reset and DUT output:
   rand logic reset_val;
   rand logic [1:0] out_pos;

   constraint priority_encoder_priority_encoder_agent_transaction_valid {
      status == IS_OK;
   }

   `uvm_object_utils_begin(priority_encoder_priority_encoder_agent_base_transaction) 
      `uvm_field_enum(kinds_e,kind,UVM_ALL_ON)
      `uvm_field_enum(status_e,status, UVM_ALL_ON)
      `uvm_field_int(sa, UVM_ALL_ON)
      `uvm_field_int(reset_val, UVM_ALL_ON)
      `uvm_field_int(out_pos, UVM_ALL_ON)
   `uvm_object_utils_end
 
   extern function new(string name = "Trans");
endclass: priority_encoder_priority_encoder_agent_base_transaction


function priority_encoder_priority_encoder_agent_base_transaction::new(string name = "Trans");
   super.new(name);
endfunction: new


class single_input_test_transaction extends priority_encoder_priority_encoder_agent_base_transaction;
   `uvm_object_utils(single_input_test_transaction)

   function new(string name = "single_input_test_transaction");
      super.new(name);
   endfunction
endclass: single_input_test_transaction


`endif // PRIORITY_ENCODER_PRIORITY_ENCODER_AGENT_TRANSACTION__SV