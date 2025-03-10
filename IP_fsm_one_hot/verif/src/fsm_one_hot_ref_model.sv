
`ifndef FSM_ONE_HOT_REF_MODEL__SV
`define FSM_ONE_HOT_REF_MODEL__SV

import uvm_pkg::*;

class fsm_one_hot_ref_model extends uvm_component;

   // Enum representing each one-hot state in a simpler form for the reference model
   typedef enum bit [3:0] {
     ST_S      = 4'd0,
     ST_S1     = 4'd1,
     ST_S11    = 4'd2,
     ST_S110   = 4'd3,
     ST_B0     = 4'd4,
     ST_B1     = 4'd5,
     ST_B2     = 4'd6,
     ST_B3     = 4'd7,
     ST_COUNT  = 4'd8,
     ST_WAIT   = 4'd9
   } fsm_state_e;

   // Internal reference model state and outputs
   fsm_state_e current_state;
   logic done_ref;
   logic counting_ref;
   logic shift_ena_ref;

   `uvm_component_utils(fsm_one_hot_ref_model)

   //----------------------------------------------------
   // new
   //----------------------------------------------------
   function new(string name="fsm_one_hot_ref_model", uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   //----------------------------------------------------
   // build_phase
   //----------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Initialize reference signals
      current_state   = ST_S;
      done_ref        = 1'b0;
      counting_ref    = 1'b0;
      shift_ena_ref   = 1'b0;
   endfunction: build_phase

   //----------------------------------------------------
   // write_input
   //----------------------------------------------------
   // Called by scoreboard or environment each time the DUT inputs are driven.
   // Instead of checking tr.kind, we now check tr.d, tr.done_counting, tr.ack.
   //----------------------------------------------------
   function void write_input(fsm_one_hot_fsm_agent_base_transaction tr);
      fsm_state_e next_state;
      logic d_sig, done_counting_sig, ack_sig;

      // 1) Extract fields from the transaction
      d_sig            = tr.d;
      done_counting_sig= tr.done_counting;
      ack_sig          = tr.ack;

      // 2) Default next_state is current_state (stays if no conditions met)
      next_state = current_state;

      // Clear default outputs each cycle
      // We'll set them as needed based on state
      done_ref      = 1'b0;
      counting_ref  = 1'b0;
      shift_ena_ref = 1'b0;

      // 3) State machine
      case (current_state)

        ST_S: begin
          // Looking for first '1'
          if (d_sig == 1'b1) 
            next_state = ST_S1;
          else
            next_state = ST_S;
          done_ref = 1'b0;
        end

        ST_S1: begin
          // Looking for second '1'
          if (d_sig == 1'b1)
            next_state = ST_S11;
          else
            next_state = ST_S;
        end

        ST_S11: begin
          if (d_sig == 1'b0)
            next_state = ST_S110;
          else
            next_state = ST_S11;  // stay in S11 on d=1
        end

        ST_S110: begin
          // Looking for final '1' => sequence 1101
          if (d_sig == 1'b1)
            next_state = ST_B0;
          else
            next_state = ST_S;
        end

        ST_B0: begin
          // shift_ena = 1
          shift_ena_ref = 1'b1;
          next_state = ST_B1;
        end

        ST_B1: begin
          shift_ena_ref = 1'b1;
          next_state = ST_B2;
        end

        ST_B2: begin
          shift_ena_ref = 1'b1;
          next_state = ST_B3;
        end

        ST_B3: begin
          shift_ena_ref = 1'b1;
          next_state = ST_COUNT;
        end


        ST_COUNT: begin
          // counting=1 while in Count
          counting_ref = 1'b1;
          // If environment is done counting, go to Wait
          if (done_counting_sig == 1'b1) begin
             next_state   = ST_WAIT;
          end
        end

        ST_WAIT: begin
          counting_ref = 1'b0; 
          // Wait asserts done=1
          done_ref = 1'b1;
          // If ack=1, go back to S
          if (ack_sig == 1'b1) begin
            next_state = ST_S;
          end
        end

        default: begin
          // Recovery from invalid states
          next_state = ST_S;
        end

      endcase // case(current_state)

      // 4) Update state
      current_state = next_state;
   endfunction: write_input

   // Accessor methods for scoreboard checks
   function logic get_done();
      return done_ref;
   endfunction: get_done

   function logic get_counting();
      return counting_ref;
   endfunction: get_counting

   function logic get_shift_ena();
      return shift_ena_ref;
   endfunction: get_shift_ena

endclass: fsm_one_hot_ref_model

`endif // FSM_ONE_HOT_REF_MODEL__SV
