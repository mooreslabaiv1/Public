




class overlappingsequencetest_sequence extends base_sequence;
  `uvm_object_utils(overlappingsequencetest_sequence)

  function new(string name="overlappingsequencetest_sequence");
    super.new(name);
  endfunction : new

  task body();
    fsm_seek_detect_fsm_seek_detect_agent_base_transaction tr;
    tr = new("overlapseq_tr");

    super.body();

    start_item(tr);
    tr.aresetn = 0;
    tr.x       = 0;
    finish_item(tr);

    start_item(tr);
    tr.aresetn = 1;
    tr.x       = 0;
    finish_item(tr);

    start_item(tr);
    tr.x = 1;
    finish_item(tr);

    start_item(tr);
    tr.x = 1;
    finish_item(tr);

    start_item(tr);
    tr.x = 0;
    finish_item(tr);

    start_item(tr);
    tr.x = 1;
    finish_item(tr);

    start_item(tr);
    tr.x = 1;
    finish_item(tr);
  endtask : body

endclass : overlappingsequencetest_sequence