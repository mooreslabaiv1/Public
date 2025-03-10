




`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_TRANSACTION__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_TRANSACTION__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class fsm_seek_detect_fsm_seek_detect_agent_base_transaction extends uvm_sequence_item;

   rand bit x;
   bit z;
   rand bit aresetn;

   `uvm_object_utils_begin(fsm_seek_detect_fsm_seek_detect_agent_base_transaction)
      `uvm_field_int(x, UVM_ALL_ON)
      `uvm_field_int(z, UVM_ALL_ON)
      `uvm_field_int(aresetn, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "Trans");
      super.new(name);
   endfunction: new

endclass: fsm_seek_detect_fsm_seek_detect_agent_base_transaction


class fsm_seek_detect_basicfunctionalitytest_transaction extends fsm_seek_detect_fsm_seek_detect_agent_base_transaction;
   `uvm_object_utils(fsm_seek_detect_basicfunctionalitytest_transaction)

   function new(string name = "fsm_seek_detect_basicfunctionalitytest_transaction");
      super.new(name);
   endfunction
endclass

`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_AGENT_TRANSACTION__SV