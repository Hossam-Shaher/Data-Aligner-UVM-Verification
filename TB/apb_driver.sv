`ifndef APB_DRIVER
  `define APB_DRIVER

  typedef class apb_seq_item_drv;

  class apb_driver extends uvm_driver#(apb_seq_item_drv);

    `uvm_component_utils(apb_driver)

    virtual apb_if apb_vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if( ! uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif) ) begin
          `uvm_error( this.get_full_name, "apb_vif NOT found" )
      end    
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      initialize();

      forever begin
        seq_item_port.get_next_item(req);
          drive(req);            
        seq_item_port.item_done();
      end
    endtask: run_phase

    extern local task initialize();

    extern local task drive(apb_seq_item_drv req);

  endclass: apb_driver

  //initialize
  task apb_driver:: initialize();
    apb_vif.psel	<= 0;
    apb_vif.penable	<= 0;
    apb_vif.pwrite 	<= 0;
    apb_vif.paddr	<= 0;
    apb_vif.pwdata	<= 0;
  endtask

  //drive
  task apb_driver:: drive(apb_seq_item_drv req);
    `uvm_info(this.get_name, req.convert2string, UVM_LOW) 

    repeat(req.pre_drive_delay) @(posedge apb_vif.pclk);

    apb_vif.psel <= 1;
    apb_vif.pwrite <= bit'(req.m_dir);
    apb_vif.paddr <= req.m_addr;
    if(req.m_dir == APB_WRITE) apb_vif.pwdata <= req.m_data;

    @(posedge apb_vif.pclk);

    apb_vif.penable <= 1;

    @(posedge apb_vif.pclk);

    while( apb_vif.pready !== 1 )  @(posedge apb_vif.pclk);

    //The following line is very IMP for uvm_reg::read to work correctly
    if( req.m_dir == APB_READ ) begin	
      req.m_data = apb_vif.prdata; 
    end

    initialize();

    repeat(req.post_drive_delay) @(posedge apb_vif.pclk);  

  endtask: drive
    
`endif //APB_DRIVER