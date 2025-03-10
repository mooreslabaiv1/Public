


`ifndef FSM_SEEK_DETECT_REF_MODEL__SV
`define FSM_SEEK_DETECT_REF_MODEL__SV

import uvm_pkg::*;
typedef class fsm_seek_detect_fsm_seek_detect_agent_base_transaction;

// -----------------------------------------------------------------------------
// Reference model for fsm_seek_detect
// -----------------------------------------------------------------------------
class fsm_seek_detect_ref_model extends uvm_component;

  `uvm_component_utils(fsm_seek_detect_ref_model)

  // Enum for FSM states
  typedef enum {S0, S1, S2} state_e;
  state_e current_state;

  function new(string name = "fsm_seek_detect_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Initialize current_state to S0 at start_of_simulation
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    current_state = S0;
  endfunction

  // Process transaction: replicate FSM logic to produce expected z
  function fsm_seek_detect_fsm_seek_detect_agent_base_transaction process_tr(fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr_in);
    fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr_out;
    tr_out = new("ref_tr");
    tr_out.x = tr_in.x;
    // Mealy output: z is 1 when current_state=S2 and x=1, else 0
    tr_out.z = (current_state == S2 && tr_in.x == 1) ? 1 : 0;
    // Next state
    case (current_state)
      S0: if (tr_in.x == 1) current_state = S1; else current_state = S0;
      S1: if (tr_in.x == 0) current_state = S2; else current_state = S1;
      S2: if (tr_in.x == 1) current_state = S1; else current_state = S0;
    endcase
    return tr_out;
  endfunction

endclass: fsm_seek_detect_ref_model

`endif // FSM_SEEK_DETECT_REF_MODEL__SV