

class serial_ip_start_bit_detection_test_test extends serial_ip_base_test;

  `uvm_component_utils(serial_ip_start_bit_detection_test_test)

  function new(string name="serial_ip_start_bit_detection_test_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    serial_start_bit_detection_test_sequence m_serial_start_bit_detection_test_seq;
    super.run_phase(phase);
    phase.raise_objection(this);

    fork
      // Create and start the serial sequence
      m_serial_start_bit_detection_test_seq = serial_start_bit_detection_test_sequence::type_id::create("m_serial_start_bit_detection_test_seq");
      m_serial_start_bit_detection_test_seq.start(m_env.m_serial_agent.m_seqr);
    join_any

    phase.drop_objection(this);
  endtask

endclass : serial_ip_start_bit_detection_test_test