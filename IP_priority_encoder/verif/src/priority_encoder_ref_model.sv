

`ifndef PRIORITY_ENCODER_REF_MODEL__SV
`define PRIORITY_ENCODER_REF_MODEL__SV

class priority_encoder_ref_model extends uvm_component;
  `uvm_component_utils(priority_encoder_ref_model)

  function new(string name = "priority_encoder_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  function logic [1:0] get_expected_output(logic [3:0] in_val, logic rst);
    logic [1:0] ret_val;
    if(rst) begin
      ret_val = 2'd0;
    end
    else begin
      if(in_val[0])       ret_val = 2'd0;
      else if(in_val[1])  ret_val = 2'd1;
      else if(in_val[2])  ret_val = 2'd2;
      else if(in_val[3])  ret_val = 2'd3;
      else                ret_val = 2'd0;
    end
    return ret_val;
  endfunction: get_expected_output

endclass: priority_encoder_ref_model

`endif // PRIORITY_ENCODER_REF_MODEL__SV