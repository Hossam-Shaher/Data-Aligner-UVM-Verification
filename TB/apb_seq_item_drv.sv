`ifndef APB_SEQ_ITEM_DRV_SV 
  `define APB_SEQ_ITEM_DRV_SV

  typedef class apb_seq_item_base;

  class apb_seq_item_drv extends apb_seq_item_base;

    `uvm_object_utils(apb_seq_item_drv)

    rand int unsigned pre_drive_delay; 
    rand int unsigned post_drive_delay;

    constraint pre_drive_delay_default {
      soft pre_drive_delay <= 5;
    }

    constraint post_drive_delay_default {
      soft post_drive_delay <= 5;
    }

    function string convert2string;
      convert2string = $sformatf("%0s, pre_drive_delay=%0d, post_drive_delay=%0d", 
                                 super.convert2string, pre_drive_delay, post_drive_delay);
    endfunction: convert2string

    function new (string name = "");
      super.new(name);
    endfunction: new

  endclass: apb_seq_item_drv

`endif //APB_SEQ_ITEM_DRV_SV