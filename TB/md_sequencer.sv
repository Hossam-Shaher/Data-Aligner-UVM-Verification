`ifndef MD_SEQUENCER_SV
  `define MD_SEQUENCER_SV

  typedef class md_seq_item_drv_master;
  typedef class md_seq_item_drv_slave;
  typedef class md_seq_item_mon;

  typedef uvm_sequencer#(md_seq_item_drv_master) 	md_sequencer_master;
  typedef uvm_sequencer#(md_seq_item_drv_slave) 	md_sequencer_slave;
  
`endif //MD_SEQUENCER_SV
