




    `ifndef FSM_ONE_HOT_SBD__SV
    `define FSM_ONE_HOT_SBD__SV

    
    class fsm_one_hot_sbd extends uvm_scoreboard;

       // TLM FIFO to receive monitor transactions
       uvm_tlm_analysis_fifo #(fsm_one_hot_fsm_agent_base_transaction) fsm_one_hot_fsm_agent_fifo;

       // Reference to the design interface (via config_db)
       typedef virtual fsm_if v_if;
       v_if scoreboard_if;

       // Reference model instance
       fsm_one_hot_ref_model ref_model;

       `uvm_component_utils(fsm_one_hot_sbd)

       extern function new(string name = "fsm_one_hot_sbd", uvm_component parent = null);
       extern virtual function void build_phase (uvm_phase phase);
       extern virtual function void connect_phase (uvm_phase phase);
       extern virtual task run_phase(uvm_phase phase);
       extern virtual function void report_phase(uvm_phase phase);

    endclass: fsm_one_hot_sbd
    
    
    function fsm_one_hot_sbd::new(string name = "fsm_one_hot_sbd", uvm_component parent);
       super.new(name,parent);
    endfunction: new
    
    function void fsm_one_hot_sbd::build_phase(uvm_phase phase);
       super.build_phase(phase);
       fsm_one_hot_fsm_agent_fifo = new("fsm_one_hot_fsm_agent_fifo", this);
       // Create the reference model
       ref_model = fsm_one_hot_ref_model::type_id::create("ref_model", this);
    endfunction: build_phase
    
    function void fsm_one_hot_sbd::connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       // Get the interface from config_db
       uvm_config_db#(v_if)::get(this, "", "fsm_agent_fsm_if", scoreboard_if);
    endfunction: connect_phase
      
    task fsm_one_hot_sbd::run_phase(uvm_phase phase);
       fsm_one_hot_fsm_agent_base_transaction tr;
       logic expected_done;
       logic expected_counting;
       logic expected_shift_ena;

       super.run_phase(phase);

       forever begin
          // Block for the next transaction
          fsm_one_hot_fsm_agent_fifo.get(tr);

          // Update the reference model
          ref_model.write_input(tr);
          expected_done      = ref_model.get_done();
          expected_counting  = ref_model.get_counting();
          expected_shift_ena = ref_model.get_shift_ena();

          // Compare DUT outputs vs. Reference Model
          if (scoreboard_if.done !== expected_done) begin
             `uvm_error("SBD_CHECK",
             $sformatf("Mismatch on 'done'. Exp = %0b, Act = %0b",
                        expected_done, scoreboard_if.done))
          end
          else if (scoreboard_if.counting !== expected_counting) begin
             `uvm_error("SBD_CHECK",
             $sformatf("Mismatch on 'counting'. Exp = %0b, Act = %0b",
                        expected_counting, scoreboard_if.counting))
          end
          else if (scoreboard_if.shift_ena !== expected_shift_ena) begin
             `uvm_error("SBD_CHECK",
             $sformatf("Mismatch on 'shift_ena'. Exp = %0b, Act = %0b",
                        expected_shift_ena, scoreboard_if.shift_ena))
          end
          else begin
             // If no mismatch, print a "PASS" message for this transaction
             `uvm_info("SBD_CHECK",
             $sformatf("All signals matched for transaction: d=%0b done_counting=%0b ack=%0b | DUT => done=%0b counting=%0b shift_ena=%0b",
                        tr.d, tr.done_counting, tr.ack,
                        scoreboard_if.done,
                        scoreboard_if.counting,
                        scoreboard_if.shift_ena),
             UVM_LOW)
          end
      end
   endtask : run_phase

    
    function void fsm_one_hot_sbd::report_phase(uvm_phase phase);
       super.report_phase(phase);
    endfunction: report_phase
    

    `endif // FSM_ONE_HOT_SBD__SV
    