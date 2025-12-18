`ifndef APB_SEQ_ITEM_MON_SV 
  `define APB_SEQ_ITEM_MON_SV

  typedef class apb_seq_item_base;

  class apb_seq_item_mon extends apb_seq_item_base;

    `uvm_object_utils(apb_seq_item_mon)

    //There is no reason to declare the properties of this class as rand
    apb_response_t 	m_response; 
    int unsigned 	m_prev_item_delay;
    int unsigned 	m_length;

    function string convert2string;
      convert2string = $sformatf("%0s, m_response=%0s, m_prev_item_delay=%0d, m_length=%0d", 
                                 super.convert2string, m_response.name(), m_prev_item_delay, m_length);
    endfunction: convert2string

    function new (string name = "");
      super.new(name);
    endfunction: new

  endclass: apb_seq_item_mon

`endif //APB_SEQ_ITEM_MON_SV