

class serial_start_bit_detection_test_sequence extends serial_base_sequence;

  `uvm_object_utils(serial_start_bit_detection_test_sequence)

  function new(string name="serial_start_bit_detection_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    serial_seqr s_seqr;
    int i;
    serial_trans_item tr;

    $cast(s_seqr, get_sequencer());
    `uvm_info(get_full_name(), $sformatf("Starting body in %s ...", get_type_name()), UVM_LOW)

    for (i = 0; i < 5; i++) begin
      tr = serial_trans_item::type_id::create($sformatf("start_bit_tr%0d", i));
      start_item(tr);

      if (i < 2) begin
        if (!tr.randomize() with { in == 1; })
          `uvm_error(get_full_name(), "Randomization failed for in==1")
      end else if (i == 2) begin
        if (!tr.randomize() with { in == 0; })
          `uvm_error(get_full_name(), "Randomization failed for in==0 (start bit)")
      end else begin
        if (!tr.randomize())
          `uvm_error(get_full_name(), "Randomization failed for random in")
      end

      finish_item(tr);
      @(posedge s_seqr.vif.clk);
    end
  endtask

endclass