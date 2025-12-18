`ifndef MD_DRIVER_SLAVE
  `define MD_DRIVER_SLAVE

  typedef class md_seq_item_drv_slave;	//REQ

  class md_driver_slave extends uvm_driver#( .REQ(md_seq_item_drv_slave) );

    `uvm_component_utils(md_driver_slave)

    virtual md_if#(`ALGN_DATA_WIDTH ) vif;
    /*
    //Implicitly done in uvm_driver
    md_seq_item_drv_slave 	req;
    */
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if( ! uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::get(this, "", "md_tx_vif", vif) ) begin
        `uvm_error( this.get_full_name, "md_tx_vif NOT found" )
      end    
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      initialize();

      forever begin
        seq_item_port.get_next_item(req);
          drive(req);            
        seq_item_port.item_done(rsp);
      end
    endtask: run_phase

    extern local task initialize();

    extern local task drive(md_seq_item_drv_slave req);

  endclass: md_driver_slave
      
  //initialize
  task md_driver_slave:: initialize();
      vif.ready <= 1;
      vif.err   <= 0;
  endtask

  //drive
  task md_driver_slave:: drive(md_seq_item_drv_slave req);
    `uvm_info(this.get_name, {"req: ", req.convert2string}, UVM_LOW) 

    #1step; //sample "vif.valid" 1 time step after posedge clk (otherwise: WRONG Results)

    while(vif.valid !== 1)     //It is important to use "LHS !== 1" instead of "LHS !== 1" to handle the case where LHS = x
    begin
        @(posedge vif.clk);
        #1step; 				//sample "vif.valid" 1 time step after posedge clk (otherwise: WRONG Results) 
    end

    vif.ready <= 0;

    repeat(req.length) @(posedge vif.clk);

    vif.ready <= 1;
    vif.err   <= bit'(req.response);

    @(posedge vif.clk);

    vif.ready <= req.ready_at_end;
    vif.err   <= 0;

  endtask: drive

`endif 	//MD_DRIVER_SLAVE