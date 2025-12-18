`ifndef APB_MONITOR
  `define APB_MONITOR

  typedef class apb_seq_item_mon;

  class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if apb_vif;
    uvm_analysis_port#(apb_seq_item_mon) ap;
    bit enable_checks = 1;
    int unsigned stuck_threshold = 1000;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      ap = new("ap", this);

      if( ! uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif) ) begin
          `uvm_error( this.get_full_name, "apb_vif NOT found" )
      end    
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      forever begin
          monitor();  
      end
    endtask: run_phase

    extern local task monitor();

  endclass: apb_monitor

  //monitor
  task apb_monitor:: monitor();
      apb_seq_item_mon item;
      item = apb_seq_item_mon::type_id::create("item");

      //It is important to use "LHS !== 1" instead of "LHS !== 1" to handle the case where LHS = x
      while(apb_vif.psel !== 1) begin  
          @(posedge apb_vif.pclk);
          item.m_prev_item_delay++;
      end

      item.m_addr   = apb_vif.paddr;
      item.m_dir    = apb_dir_t'(apb_vif.pwrite);

      if(item.m_dir == APB_WRITE) begin
          item.m_data = apb_vif.pwdata;
      end

      item.m_length = 1;

      @(posedge apb_vif.pclk);
      item.m_length++;

      while(apb_vif.pready !== 1) begin
          @(posedge apb_vif.pclk);
          item.m_length++;

          //RULE 5 (Protocol checks)
          if(enable_checks == 1) begin
              RULE_5: assert(item.m_length <= stuck_threshold) else begin
                `uvm_fatal("PROTOCOL_ERROR", $sformatf("The APB transfer reached the stuck threshold value of %0d", item.m_length))
              end
          end
      end

      item.m_response = apb_response_t'(apb_vif.pslverr);

      if(item.m_dir == APB_READ) begin
         item.m_data = apb_vif.prdata;
      end

      ap.write(item);

      @(posedge apb_vif.pclk);

      `uvm_info(this.get_name, item.convert2string, UVM_LOW) 
  endtask: monitor
    
`endif //APB_MONITOR