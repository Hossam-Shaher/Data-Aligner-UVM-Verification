`ifndef MD_SEQ_ITEM_DRV_SV 
  `define MD_SEQ_ITEM_DRV_SV

  typedef class md_seq_item_base;

  class md_seq_item_drv_base extends md_seq_item_base;

    `uvm_object_utils(md_seq_item_drv_base)

    function new (string name = "");
      super.new(name);
    endfunction

  endclass: md_seq_item_drv_base

  /**********************************************************/

  class md_seq_item_drv_master extends md_seq_item_drv_base;

    `uvm_object_utils(md_seq_item_drv_master)

    rand int unsigned 	pre_drive_delay;
    rand int unsigned 	post_drive_delay;
    rand bit [`ALGN_DATA_WIDTH - 1 : 0] 	data;
    rand int unsigned 	offset;
    rand int unsigned	size;

    constraint pre_drive_delay_default {
      soft pre_drive_delay <= 5;
    }

    constraint post_drive_delay_default {
      soft post_drive_delay <= 5;
    }

    constraint data_default {
      soft size == 1;
    }

    constraint data_hard {
      size > 0;
    }

    constraint offset_default {
      soft offset == 0;
    }

    function string convert2string;
      convert2string = 
      $sformatf("pre_drive_delay = %0d, post_drive_delay = %0d, data = %0h, offset = %0h, size = %0h", 
                 pre_drive_delay, post_drive_delay, data, offset, size);
    endfunction: convert2string

    function new (string name = "");
      super.new(name);
    endfunction

  endclass: md_seq_item_drv_master

  /**********************************************************/

  class md_seq_item_drv_slave extends md_seq_item_drv_base;

    `uvm_object_utils(md_seq_item_drv_slave)

    //This controls after how many cycles the "ready" signal will be high
    //A value of 0 means that the MD item will be one clock cycle long
    rand int unsigned length;

    rand md_response_t response; 	//drives vif.err based on on "vif.offset" and "vif.size"

    rand bit ready_at_end;			//drives vif.ready at the end of the MD item 

    constraint length_default {
      soft length <= 5;
    }

    function string convert2string;
      convert2string = $sformatf("length: %0d, response: %0s, ready_at_end: %0d", length, response.name(), ready_at_end);
    endfunction: convert2string

    function new (string name = "");
      super.new(name);
    endfunction

  endclass: md_seq_item_drv_slave

`endif //MD_SEQ_ITEM_DRV_SV