`ifndef MD_SEQ_ITEM_BASE_SV 
  `define MD_SEQ_ITEM_BASE_SV

  class md_seq_item_base extends uvm_sequence_item;

    `uvm_object_utils(md_seq_item_base)

    function new (string name = "");
      super.new(name);
    endfunction

  endclass: md_seq_item_base

`endif //MD_SEQ_ITEM_BASE_SV