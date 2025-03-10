


class fsm_seek_detect_basicfunctionalitytest_sequence extends base_sequence;

  `uvm_object_utils(fsm_seek_detect_basicfunctionalitytest_sequence)

  function new(string name = "fsm_seek_detect_basicfunctionalitytest_sequence");
    super.new(name);
  endfunction

  task body();
    fsm_seek_detect_basicfunctionalitytest_transaction tr0;
    fsm_seek_detect_basicfunctionalitytest_transaction tr1;
    fsm_seek_detect_basicfunctionalitytest_transaction tr2;
    fsm_seek_detect_basicfunctionalitytest_transaction tr3;
    
    `uvm_info(get_type_name(), "Starting basicfunctionalitytest_sequence", UVM_LOW)

    tr0 = new("tr0");
    tr0.x = 0;
    start_item(tr0);
    finish_item(tr0);

    tr1 = new("tr1");
    tr1.x = 1;
    start_item(tr1);
    finish_item(tr1);

    tr2 = new("tr2");
    tr2.x = 0;
    start_item(tr2);
    finish_item(tr2);

    tr3 = new("tr3");
    tr3.x = 1;
    start_item(tr3);
    finish_item(tr3);

  endtask

endclass: fsm_seek_detect_basicfunctionalitytest_sequence