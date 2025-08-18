

class serial_ip_full_byte_reception_with_valid_signals_test extends serial_ip_base_test;

  `uvm_component_utils(serial_ip_full_byte_reception_with_valid_signals_test)

  function new(string name="serial_ip_full_byte_reception_with_valid_signals_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    serial_full_byte_reception_with_valid_signals_sequence m_serial_full_byte_reception_with_valid_signals_seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    fork
      m_serial_full_byte_reception_with_valid_signals_seq = serial_full_byte_reception_with_valid_signals_sequence::type_id::create("m_serial_full_byte_reception_with_valid_signals_seq");
      m_serial_full_byte_reception_with_valid_signals_seq.start(m_env.m_serial_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask : run_phase

endclass : serial_ip_full_byte_reception_with_valid_signals_test