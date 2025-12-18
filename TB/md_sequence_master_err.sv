`ifndef MD_SEQUENCE_MASTER_ERR_SV
  `define MD_SEQUENCE_MASTER_ERR_SV

  typedef class md_sequence_master;

  class md_sequence_master_err extends md_sequence_master;

    `uvm_object_utils(md_sequence_master_err)

    constraint illegal_rx_hard {
      ( ((`ALGN_DATA_WIDTH / 8) + item.offset) % item.size != 0 ) ||
      ( (item.size + item.offset) > (`ALGN_DATA_WIDTH / 8) );
    }

    function new(string name = "");
      super.new(name);
    endfunction: new

  endclass: md_sequence_master_err

`endif //MD_SEQUENCE_MASTER_ERR_SV