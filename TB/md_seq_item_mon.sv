`ifndef MD_SEQ_ITEM_MON_SV 
`define MD_SEQ_ITEM_MON_SV

typedef class md_seq_item_base;

class md_seq_item_mon extends md_seq_item_base;

  `uvm_object_utils(md_seq_item_mon)
  
  //There is no reason to declare the properties of this class as rand
  bit [`ALGN_DATA_WIDTH - 1 : 0] 	data;
  int unsigned 		offset;
  int unsigned		size;
  	
  md_response_t 	response;  
  int unsigned 		length;
  int unsigned 		prev_item_delay;
    
  function string convert2string;
    convert2string = 
    $sformatf("begin_time = %0d, end_time = %0d, data = %0h, offset = %0h, size = %0h, response= %0s, length= %0d, prev_item_delay= %0d", 
              get_begin_time()-1, get_end_time(), data, offset, size, response.name(), length, prev_item_delay);
  endfunction: convert2string
  
  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
     md_seq_item_mon item;
     bit status = 1;
     $cast(item, rhs);
     
     status &= super.do_compare(rhs, comparer);		//In this case, super.do_compre always return 1
     status &= (this.data === item.data);
     status &= (this.offset === item.offset);
     status &= (this.size === item.size);
     status &= (this.response === item.response);
     //status &= (this.length === item.length);
     //status &= (this.prev_item_delay === item.prev_item_delay);
     
     return status;
  endfunction

  function new (string name = "");
    super.new(name);
  endfunction

endclass: md_seq_item_mon

`endif //MD_SEQ_ITEM_MON_SV