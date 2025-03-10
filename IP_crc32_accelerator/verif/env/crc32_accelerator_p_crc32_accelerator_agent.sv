

`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT__SV

class crc32_accelerator_p_crc32_accelerator_agent extends uvm_agent;
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  crc32_accelerator_p_crc32_accelerator_agent_base_seqr base_sqr;

  crc32_accelerator_p_crc32_accelerator_driver drv;
  crc32_accelerator_p_crc32_accelerator_monitor mon;

  `uvm_component_utils_begin(crc32_accelerator_p_crc32_accelerator_agent)
  `uvm_component_utils_end

  function new(string name = "mast_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    mon = crc32_accelerator_p_crc32_accelerator_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      base_sqr = crc32_accelerator_p_crc32_accelerator_agent_base_seqr::type_id::create("base_sqr", this);
      drv = crc32_accelerator_p_crc32_accelerator_driver::type_id::create("drv", this);
    end
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(base_sqr.seq_item_export);
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction

endclass: crc32_accelerator_p_crc32_accelerator_agent

`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_AGENT__SV