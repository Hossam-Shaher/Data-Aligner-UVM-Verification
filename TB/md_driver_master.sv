`ifndef MD_DRIVER_MASTER
  `define MD_DRIVER_MASTER

  typedef class md_seq_item_drv_master;

  class md_driver_master extends uvm_driver#(md_seq_item_drv_master);

    `uvm_component_utils(md_driver_master)

    virtual md_if#(`ALGN_DATA_WIDTH ) vif;
    md_seq_item_drv_master item;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if( ! uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::get(this, "", "md_rx_vif", vif) ) begin
          `uvm_error( this.get_full_name, "md_rx_vif NOT found" )
      end    
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      initialize();

      forever begin
        seq_item_port.get_next_item(item);
          drive(item);            
        seq_item_port.item_done();
      end
    endtask: run_phase
    
    extern local task initialize();
      
    extern local task drive(md_seq_item_drv_master item);  

  endclass: md_driver_master
      
  //initialize
  task md_driver_master:: initialize();
    vif.valid  <= 0;
    vif.data   <= 0;
    vif.offset <= 0;
    vif.size   <= 0;
  endtask

  //drive
  task md_driver_master:: drive(md_seq_item_drv_master item);
    `uvm_info(this.get_name, item.convert2string, UVM_NONE) 

    if(item.offset + item.size > `ALGN_DATA_WIDTH / 8) begin
      `uvm_fatal("ALGORITHM_ISSUE", 
                  $sformatf("Trying to drive an item with offset %0d and %0d bytes but the width of the data bus (in bytes) is %0d",
                             item.offset, item.size, `ALGN_DATA_WIDTH  / 8) )
    end

    repeat (item.pre_drive_delay) @(posedge vif.clk);

    vif.valid  	<= 1;

    vif.data 	<= item.data;  
    vif.offset 	<= item.offset;
    vif.size   	<= item.size;

    @(posedge vif.clk);

    while(vif.ready !== 1) @(posedge vif.clk);	// Use !== and not !=

    initialize();

    repeat(item.post_drive_delay) @(posedge vif.clk);

  endtask: drive

`endif //MD_DRIVER_MASTER