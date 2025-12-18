`ifndef MD_SEQUENCE_MASTER_SV
  `define MD_SEQUENCE_MASTER_SV

  typedef class md_seq_item_drv_master;

  class md_sequence_master extends uvm_sequence#(md_seq_item_drv_master);

    `uvm_object_utils(md_sequence_master)

    rand md_seq_item_drv_master item;

    constraint item_hard {
        item.size 	> 	0;
        item.size 	<= 	`ALGN_DATA_WIDTH / 8;
        item.offset <	`ALGN_DATA_WIDTH / 8;
        item.size + item.offset <= `ALGN_DATA_WIDTH / 8;
      }

    function new(string name = "");
      super.new(name);
      item = md_seq_item_drv_master::type_id::create("item"); 
      //do NOT insert a 2nd actual argument "this", bcz "this" shall be a component
      item.data_default.constraint_mode(0);
      item.offset_default.constraint_mode(0);
    endfunction: new

    task body();
      start_item(item);
      finish_item(item);    
    endtask: body

  endclass: md_sequence_master

`endif //MD_SEQUENCE_MASTER_SV