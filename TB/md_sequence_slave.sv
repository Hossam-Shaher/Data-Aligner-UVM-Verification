`ifndef MD_SEQUENCE_SLAVE_SV
  `define MD_SEQUENCE_SLAVE_SV

  typedef class md_seq_item_drv_slave;	//REQ

  class md_sequence_slave extends uvm_sequence#( .REQ(md_seq_item_drv_slave) );
    
    `uvm_object_utils(md_sequence_slave)
  
    rand md_seq_item_drv_slave req;
  
    function new(string name = "");
      super.new(name);
    endfunction: new
 
    task body();
      forever begin 
        req = md_seq_item_drv_slave::type_id::create("req");

        start_item(req);
        assert ( req.randomize() );
        finish_item(req);
      end
    endtask: body

  endclass: md_sequence_slave

`endif 	//MD_SEQUENCE_SLAVE_SV