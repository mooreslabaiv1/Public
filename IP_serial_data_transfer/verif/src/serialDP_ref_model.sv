`ifndef SERIALDP_REF_MODEL__SV
`define SERIALDP_REF_MODEL__SV

import uvm_pkg::*;

//------------------------------------------------------------
// CLASS: serialDP_ref_model
// A reference model that:
//
// 1) Stores a 10-bit frame (start + 8 data + parity) in 'frame_bits'
//    plus a separate 'stop_bit'.
// 2) Replicates the DUT logic for checking if start=0, data+parity => odd # of 1s, and stop=1.
// 3) Provides getters for each piece: start bit, data bits, parity bit, stop bit, and the computed 'ref_done'.
//
// The scoreboard can call these getter methods to do a full, bit-by-bit comparison.
//------------------------------------------------------------
class serialDP_ref_model extends uvm_component;

   `uvm_component_utils(serialDP_ref_model)

   // ----------------------------------------------------
   // Internal storage:
   //   frame_bits[0]  = start bit
   //   frame_bits[1..8] = data bits (LSB..MSB)
   //   frame_bits[9]  = parity bit
   //   stop_b         = final "stop" bit
   //   ref_done       = computed '1' if all checks pass, else '0'
   // ----------------------------------------------------
   protected bit [9:0] frame_bits;
   protected bit       stop_b;
   protected bit       ref_done;

   // ----------------------------------------------------
   // CONSTRUCTOR
   // ----------------------------------------------------
   function new(string name="", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   // ----------------------------------------------------
   // set_frame(...) => scoreboard calls this each time
   // it has a new 10-bit frame plus a stop bit.
   // This method computes 'ref_done' according to the
   // same logic the DUT uses.
   // ----------------------------------------------------
   function void set_frame(bit [9:0] fbits, bit sb);
      frame_bits = fbits;
      stop_b     = sb;

      ref_done   = compute_done_10bits(fbits, sb);
   endfunction: set_frame

   // ----------------------------------------------------
   // compute_done_10bits(...) => replicate the DUT logic:
   //   1) start bit = 0
   //   2) data[1..8] + parity[9] => odd # of 1s
   //   3) stop bit = 1
   // => returns '1' if all pass, else '0'
   // ----------------------------------------------------
   protected function bit compute_done_10bits(bit [9:0] fbits, bit sb);
      int count_ones;
      // 1) Check start=0
      if (fbits[0] != 0)
         return 0;

      // 2) Check odd parity for fbits[1..9]
      count_ones = 0;
      for (int i=1; i<=9; i++) begin
         if (fbits[i]) count_ones++;
      end
      if ((count_ones % 2) != 1)
         return 0;

      // 3) Check stop bit=1
      if (!sb)
         return 0;

      // If all good => done=1
      return 1;
   endfunction: compute_done_10bits

   // ----------------------------------------------------
   // GETTERS for each field
   // ----------------------------------------------------

   // Return the entire 10-bit frame
   function bit [9:0] get_full_frame();
      return frame_bits;
   endfunction: get_full_frame

   // Return start bit = frame_bits[0]
   function bit get_start_bit();
      return frame_bits[0];
   endfunction: get_start_bit

   // Return the data bits from frame_bits[1..8]
   function logic [7:0] get_data_bits();
      return frame_bits[8:1];
   endfunction: get_data_bits

   // Return the parity bit = frame_bits[9]
   function bit get_parity_bit();
      return frame_bits[9];
   endfunction: get_parity_bit

   // Return the final stop bit
   function bit get_stop_bit();
      return stop_b;
   endfunction: get_stop_bit

   // Return the computed 'ref_done' (1 or 0)
   function bit get_ref_done();
      return ref_done;
   endfunction: get_ref_done

endclass: serialDP_ref_model

`endif // SERIALDP_REF_MODEL__SV
