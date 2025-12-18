`ifndef MD_MONITOR
  `define MD_MONITOR

  typedef class md_seq_item_mon;

  class md_monitor extends uvm_monitor;

    `uvm_component_utils(md_monitor)

    virtual md_if#(`ALGN_DATA_WIDTH ) 	vif;
    uvm_analysis_port#(md_seq_item_mon)	ap;
    bit enable_checks = 1;
    int unsigned stuck_threshold = 1000;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      ap = new("ap", this);

      if( ! uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::get(this, "", "md_vif", vif) ) begin
          `uvm_error( this.get_full_name, "md_rx_vif NOT found" )
      end   
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      forever begin
          monitor();  
      end
    endtask: run_phase

    extern local task monitor();

  endclass: md_monitor
      
  //monitor
  task md_monitor:: monitor();
    md_seq_item_mon item;
    item = md_seq_item_mon::type_id::create("item");

    #1step; 					//sample "vif.valid" 1 time step after posedge clk (otherwise: WRONG Results)

    while(vif.valid !== 1)     	//It is important to use "LHS !== 1" instead of "LHS !== 1" to handle the case where LHS = x
    begin
        @(posedge vif.clk);
        item.prev_item_delay++;
        #1step; 				//sample "vif.valid" 1 time step after posedge clk (otherwise: WRONG Results) 
    end

    void'(begin_tr(item));	//Call begin_tr (a method of uvm_transaction); set/ override the "internal start time"

    item.offset = vif.offset;
    item.size 	= vif.size;
    item.data 	= vif.data;
    item.length = 1;

    @(posedge vif.clk);

    while(vif.ready !== 1) begin
      @(posedge vif.clk);
      item.length++;

      //RULE 16 (Protocol checks)
      if(enable_checks == 1) begin
        RULE_16: assert(item.length <= stuck_threshold) else begin
          `uvm_fatal("PROTOCOL_ERROR", $sformatf("The MD transfer reached the stuck threshold value of %0d", item.length))
        end
      end
    end

    item.response = md_response_t'(vif.err);

    //Call end_tr (a method of uvm_transaction; void function)
    end_tr(item);
    ap.write(item);

    `uvm_info(this.get_name, item.convert2string, UVM_LOW) 
  endtask: monitor

`endif //MD_MONITOR