`ifndef APB_SEQ_ITEM_BASE_SV 
  `define APB_SEQ_ITEM_BASE_SV

  class apb_seq_item_base extends uvm_sequence_item;

    `uvm_object_utils(apb_seq_item_base)

    rand apb_dir_t 		m_dir;
    rand logic [15:0] 	m_addr;
    rand logic [31:0] 	m_data;

    function string convert2string;
      convert2string = $sformatf("m_dir=%0s, m_addr=%0h, m_data=%0h", 
                                 m_dir.name, m_addr, m_data);
    endfunction: convert2string

    function new (string name = "");
      super.new(name);
    endfunction: new

  endclass: apb_seq_item_base

`endif //APB_SEQ_ITEM_BASE_SV