`ifndef WEIGHTED_ROUND_ROBIN_BURSTY_TRAFFIC_TEST_SEQUENCE__SV
`define WEIGHTED_ROUND_ROBIN_BURSTY_TRAFFIC_TEST_SEQUENCE__SV

// Virtual Sequencer
class bursty_traffic_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(bursty_traffic_virtual_sequencer)

  weighted_round_robin_requestor_agent_base_seqr       requestor_seqr;
  weighted_round_robin_priority_update_agent_base_seqr priority_update_seqr;

  function new(string name = "bursty_traffic_virtual_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass

// Priority Sub-sequence
class bursty_traffic_prio_subseq extends weighted_round_robin_priority_update_base_sequence;
  `uvm_object_utils(bursty_traffic_prio_subseq)

  function new(string name = "bursty_traffic_prio_subseq");
    super.new(name);
  endfunction

  virtual task body();
    weighted_round_robin_priority_update_agent_base_transaction prio_item;
    int N = 32;

    // Example: half at 3, half at 2
    for (int i=0; i<N; i++) begin
      prio_item = weighted_round_robin_priority_update_agent_base_transaction
                  ::type_id::create($sformatf("burst_prio_%0d", i));

      // We forcibly set prio_id, prio, prio_upt=1
      if (!prio_item.randomize() with {
         prio_id == i;
         prio_upt == 1;
         if (i < (N/2)) prio == 4'd3;
         else           prio == 4'd2;
      }) begin
        `uvm_error("PRIO_RAND_FAIL","Failed to randomize burst prio transaction")
      end

      start_item(prio_item);
      finish_item(prio_item);
    end
  endtask
endclass

// We'll define a specialized "bursty_req_tx" transaction to handle # bits
class bursty_req_tx extends weighted_round_robin_requestor_agent_base_transaction;

   // Add a rand integer for #bits or random idle cycles
   rand int num_bits_set;
   constraint c_num_bits_set_range { num_bits_set inside {[0:32]}; }

   // We'll override the 'req' bits in post_randomize
   function void post_randomize();
      // Clear it
      this.req = '0;
      // Set exactly num_bits_set bits (or partial approach)
      // For a simple approach: pick random bit positions
      for (int i=0; i<num_bits_set; i++) begin
         int bitpos = $urandom_range(0,31);
         this.req[bitpos] = 1'b1;
      end
   endfunction

   `uvm_object_utils_begin(bursty_req_tx)
     `uvm_field_int(num_bits_set, UVM_ALL_ON)
     // 'req' already declared in super, no need to re-field
   `uvm_object_utils_end

   function new(string name="bursty_req_tx");
      super.new(name);
   endfunction
endclass


class bursty_traffic_req_subseq extends weighted_round_robin_requestor_base_sequence;
  `uvm_object_utils(bursty_traffic_req_subseq)

  function new(string name = "bursty_traffic_req_subseq");
    super.new(name);
  endfunction

  virtual task body();
    bursty_req_tx req_tr;
    int burst_count = 5;
    int burst_size  = 4;
    int idle_cycles;

    for (int b=0; b<burst_count; b++) begin
      `uvm_info(get_type_name(), $sformatf("Starting burst #%0d", b), UVM_LOW);

      // Drive "burst_size" consecutive request transactions
      for (int s=0; s<burst_size; s++) begin
        req_tr = bursty_req_tx::type_id::create($sformatf("req_b%0d_s%0d", b, s));

        // randomize the request item => picks how many bits => sets them in post_randomize
        if (!req_tr.randomize()) begin
          `uvm_error("REQ_RAND_FAIL","Failed to randomize bursty_req_tx")
        end

        start_item(req_tr);
        finish_item(req_tr);
      end

      idle_cycles = $urandom_range(3,20);

      `uvm_info(get_type_name(), 
        $sformatf("Burst #%0d done; waiting %0d cycles", b, idle_cycles),
        UVM_LOW);

      repeat (idle_cycles) @(posedge p_sequencer.drv_if.clk);

    end
  endtask
endclass

// Top-level Virtual Sequence
class bursty_traffic_test_sequence extends uvm_sequence;
  `uvm_object_utils(bursty_traffic_test_sequence)
  `uvm_declare_p_sequencer(bursty_traffic_virtual_sequencer)

  function new(string name = "bursty_traffic_test_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bursty_traffic_prio_subseq prio_seq;
    bursty_traffic_req_subseq  req_seq;

    prio_seq = bursty_traffic_prio_subseq::type_id::create("prio_seq");
    req_seq  = bursty_traffic_req_subseq::type_id::create("req_seq");

    fork
      prio_seq.start(p_sequencer.priority_update_seqr);
      req_seq.start(p_sequencer.requestor_seqr);
    join
  endtask
endclass

`endif // WEIGHTED_ROUND_ROBIN_BURSTY_TRAFFIC_TEST_SEQUENCE__SV
