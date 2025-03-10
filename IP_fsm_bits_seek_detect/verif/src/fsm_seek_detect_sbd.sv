


    `ifndef FSM_SEEK_DETECT_SBD__SV
    `define FSM_SEEK_DETECT_SBD__SV

    
    class fsm_seek_detect_sbd extends uvm_scoreboard;

       // TLM FIFO to receive transactions from the monitor
       uvm_tlm_analysis_fifo #(fsm_seek_detect_fsm_seek_detect_agent_base_transaction) fsm_seek_detect_fsm_seek_detect_agent_fifo;
       
       // Reference model handle
       fsm_seek_detect_ref_model ref_model;

       `uvm_component_utils(fsm_seek_detect_sbd)
    	function new(string name = "fsm_seek_detect_sbd",
                     uvm_component parent = null); 
    		super.new(name,parent);
    	endfunction: new

    	virtual function void build_phase (uvm_phase phase);
    		super.build_phase(phase);
    		fsm_seek_detect_fsm_seek_detect_agent_fifo = new("fsm_seek_detect_fsm_seek_detect_agent_fifo", this);
    		// Create the reference model
    		ref_model = fsm_seek_detect_ref_model::type_id::create("ref_model", this);
    	endfunction: build_phase

    	virtual function void connect_phase (uvm_phase phase);
    		super.connect_phase(phase);
    	endfunction: connect_phase

    	// Main phase is kept empty per code skeleton
    	virtual task main_phase(uvm_phase phase);
    		super.main_phase(phase);
    	endtask: main_phase

    	// Use run_phase to compare DUT vs reference
    	virtual task run_phase(uvm_phase phase);
    		fsm_seek_detect_fsm_seek_detect_agent_base_transaction dut_tr;
    		fsm_seek_detect_fsm_seek_detect_agent_base_transaction ref_tr;
    		super.run_phase(phase);
    		forever begin
    			fsm_seek_detect_fsm_seek_detect_agent_fifo.get(dut_tr);
    			ref_tr = ref_model.process_tr(dut_tr);
    			if (dut_tr.z !== ref_tr.z) begin
    				`uvm_error("FSM_SEEK_DETECT_SBD", $sformatf("Mismatch detected: input x=%0b, DUT z=%0b, expected z=%0b", dut_tr.x, dut_tr.z, ref_tr.z));
    			end
				else begin
					`uvm_info("FSM_SEEK_DETECT_SBD", $sformatf("Match detected"), UVM_LOW)
				end
    		end
    	endtask: run_phase

    	virtual function void report_phase(uvm_phase phase);
    		super.report_phase(phase);
    	endfunction: report_phase

    endclass: fsm_seek_detect_sbd
    

    `endif // FSM_SEEK_DETECT_SBD__SV
    