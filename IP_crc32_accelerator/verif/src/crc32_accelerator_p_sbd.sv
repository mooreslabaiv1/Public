

`ifndef CRC32_ACCELERATOR_P_SBD__SV
`define CRC32_ACCELERATOR_P_SBD__SV

       `uvm_analysis_imp_decl(_crc32_accelerator_agent_ingress)
     


class crc32_accelerator_p_sbd extends uvm_scoreboard;

   uvm_analysis_imp_crc32_accelerator_agent_ingress #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction,crc32_accelerator_p_sbd) before_crc32_accelerator_p_crc32_accelerator_agent_export;
   extern function void write_crc32_accelerator_agent_ingress(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr);


   uvm_tlm_analysis_fifo #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction) in_fifo;
   uvm_tlm_analysis_fifo #(crc32_accelerator_p_crc32_accelerator_agent_base_transaction) out_fifo;

   crc32_accelerator_p_reference_model ref_model;

   `uvm_component_utils(crc32_accelerator_p_sbd)
   extern function new(string name = "crc32_accelerator_p_sbd",
                       uvm_component parent = null); 
   extern virtual function void build_phase (uvm_phase phase);
   extern virtual function void connect_phase (uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);

endclass: crc32_accelerator_p_sbd

function crc32_accelerator_p_sbd::new(string name = "crc32_accelerator_p_sbd",
                         uvm_component parent);
   super.new(name,parent);
endfunction: new

function void crc32_accelerator_p_sbd::build_phase(uvm_phase phase);
    super.build_phase(phase);

    in_fifo = new("in_fifo", this);
    out_fifo = new("out_fifo", this);

    ref_model = crc32_accelerator_p_reference_model::type_id::create("ref_model", this);

endfunction:build_phase

function void crc32_accelerator_p_sbd::connect_phase(uvm_phase phase);
endfunction:connect_phase

task crc32_accelerator_p_sbd::main_phase(uvm_phase phase);
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction in_tr;
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction out_tr;
    crc32_accelerator_p_crc32_accelerator_agent_base_transaction expected_tr;

    logic [31:0] prev_crc_out;
    logic        prev_crc_valid;
    logic        data_valid;

    int reset_detected = 0;

    super.main_phase(phase);

    ref_model.reset();
    prev_crc_out = 32'hFFFF_FFFF;
    prev_crc_valid = 0;

    forever begin
            out_fifo.get(out_tr);
            data_valid = out_tr.data_valid;

            // Check for reset behavior
            if (out_tr.crc_valid === 0 && out_tr.crc_out == 32'hFFFF_FFFF && data_valid === 0) begin
                if (!reset_detected) begin
                    reset_detected = 1;
                    ref_model.reset();
                    `uvm_info(get_full_name(), "Reset behavior observed.", UVM_LOW)
                    if (out_tr.crc_out !== 32'hFFFF_FFFF) begin
                        `uvm_error(get_full_name(), "CRC register did not reset to 0xFFFFFFFF after reset.")
                    end else begin
                        `uvm_info(get_full_name(), "CRC register correctly reset to 0xFFFFFFFF.", UVM_LOW)
                    end
                    if (out_tr.crc_valid !== 0) begin
                        `uvm_error(get_full_name(), "CRC valid is not low after reset.")
                    end else begin
                        `uvm_info(get_full_name(), "CRC valid correctly low after reset.", UVM_LOW)
                    end
                end
            end
            else begin
                reset_detected = 0;
            end 

            // When crc_valid is asserted, compare the crc_out
            if (out_tr.crc_valid) begin
                expected_tr = crc32_accelerator_p_crc32_accelerator_agent_base_transaction::type_id::create("expected_tr");
                expected_tr.crc_out = ~ref_model.crc_reg; // Complement of crc_reg
                expected_tr.crc_valid = out_tr.crc_valid;
                if (~expected_tr.crc_out !== out_tr.crc_out) begin
                    `uvm_error(get_full_name(), $sformatf("CRC Mismatch: Expected=0x%8h, Got=0x%8h", expected_tr.crc_out, out_tr.crc_out))
                end else begin
                    `uvm_info(get_full_name(), "CRC Match", UVM_LOW)
                end
            end
            else begin
                // Monitor no changes when data_valid is low
                if (!data_valid && (reset_detected == 0)) begin
                    if ((prev_crc_out !== out_tr.crc_out) ) begin
                        `uvm_error(get_full_name(), $sformatf("CRC or crc_valid changed when data_valid is low. Previous CRC=0x%8h, Current CRC=0x%8h", prev_crc_out, out_tr.crc_out))
                    end
                end 
            end

            if (data_valid) begin
                // When data_valid is high, update reference model
                ref_model.calculate_crc(out_tr.data_in);
            end            

            // Update previous crc_out and crc_valid
            prev_crc_out = out_tr.crc_out;
            prev_crc_valid = out_tr.crc_valid;

    end

endtask: main_phase

function void crc32_accelerator_p_sbd::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction:report_phase

function void crc32_accelerator_p_sbd::write_crc32_accelerator_agent_ingress(crc32_accelerator_p_crc32_accelerator_agent_base_transaction tr);
// User needs to add functionality here 
$display("Inside write function");
endfunction


`endif // CRC32_ACCELERATOR_P_SBD__SV