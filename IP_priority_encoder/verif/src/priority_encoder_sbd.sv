


    `ifndef PRIORITY_ENCODER_SBD__SV
    `define PRIORITY_ENCODER_SBD__SV

    
    class priority_encoder_sbd extends uvm_scoreboard;

       // Reference model instance
       priority_encoder_ref_model ref_model;
       
       // Transaction queue (TLM FIFO)
       uvm_tlm_analysis_fifo #(priority_encoder_priority_encoder_agent_base_transaction) priority_encoder_priority_encoder_agent_fifo;

       `uvm_component_utils(priority_encoder_sbd)

       function new(string name = "priority_encoder_sbd",
                    uvm_component parent = null);
          super.new(name,parent);
       endfunction: new
    
       virtual function void build_phase (uvm_phase phase);
          super.build_phase(phase);
          priority_encoder_priority_encoder_agent_fifo = new("priority_encoder_priority_encoder_agent_fifo", this);
          // Create reference model
          ref_model = priority_encoder_ref_model::type_id::create("ref_model", this);
       endfunction: build_phase

       virtual function void connect_phase (uvm_phase phase);
          super.connect_phase(phase);
       endfunction: connect_phase

       virtual task run_phase(uvm_phase phase);
          priority_encoder_priority_encoder_agent_base_transaction tr;
          logic [1:0] expected_val;
          super.run_phase(phase);
         `uvm_info("SCOREBOARD", $sformatf("Entered Scoreboard"), UVM_LOW);
          forever begin
             priority_encoder_priority_encoder_agent_fifo.get(tr);
             expected_val = ref_model.get_expected_output(tr.sa[3:0], tr.reset_val);
             if (expected_val != tr.out_pos) begin
                `uvm_error("SCOREBOARD", $sformatf("Mismatch! in=%b expected=%0d actual=%0d", tr.sa[3:0], expected_val, tr.out_pos));
             end
             else begin
                `uvm_info("SCOREBOARD", $sformatf("Match. in=%b pos=%0d", tr.sa[3:0], tr.out_pos), UVM_LOW);
             end
          end
       endtask: run_phase
    
       virtual function void report_phase(uvm_phase phase);
          super.report_phase(phase);
       endfunction: report_phase
    
    endclass: priority_encoder_sbd
    
    
    `endif // PRIORITY_ENCODER_SBD__SV
    