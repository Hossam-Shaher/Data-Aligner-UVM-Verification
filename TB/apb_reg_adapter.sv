`ifndef APB_REG_ADAPTER_SV
  `define APB_REG_ADAPTER_SV
 
  typedef class apb_seq_item_mon;
  typedef class apb_seq_item_drv;
    
  class apb_reg_adapter extends uvm_reg_adapter;
    
    `uvm_object_utils(apb_reg_adapter)
    
    function new(string name = "");
      super.new(name);  
    endfunction: new
    
    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      apb_seq_item_mon item_mon;
      apb_seq_item_drv item_drv;
      
      if( $cast(item_mon, bus_item) ) begin
        rw.kind   = (item_mon.m_dir == APB_WRITE)? UVM_WRITE : UVM_READ;
        rw.addr   = item_mon.m_addr;
        rw.data   = item_mon.m_data;
        rw.status = (item_mon.m_response == APB_OKAY)? UVM_IS_OK : UVM_NOT_OK;
      
      end else if ( $cast(item_drv, bus_item) ) begin
        rw.kind   = (item_drv.m_dir == APB_WRITE)? UVM_WRITE : UVM_READ;
        rw.addr   = item_drv.m_addr;
        rw.data   = item_drv.m_data;
        rw.status = UVM_IS_OK;
      
      end  else
        `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Class not supported: %0s", bus_item.get_type_name()))
      
    endfunction: bus2reg
    
    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
		apb_seq_item_drv item = apb_seq_item_drv::type_id::create("item");
      
      	item.m_dir  = (rw.kind == UVM_WRITE) ? APB_WRITE : APB_READ;
        item.m_data = rw.data;
        item.m_addr = rw.addr;
     
      	return item;
    endfunction: reg2bus
    
  endclass: apb_reg_adapter

`endif //APB_REG_ADAPTER_SV