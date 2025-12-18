`ifndef ALGN_MODEL_SV
  `define ALGN_MODEL_SV

  typedef class algn_reg_block;
  typedef class md_seq_item_mon;
    
  `uvm_analysis_imp_decl(_in_rx) 	// Class: uvm_analysis_imp_in_rx	Method: write_in_rx
  `uvm_analysis_imp_decl(_in_tx)	// Class: uvm_analysis_imp_in_tx	Method: write_in_tx

  class algn_model extends uvm_component;
    
    `uvm_component_utils(algn_model)
    
    /**************************************************************************************************************************/
    /****************************************************    PROPERTIES    ****************************************************/
    /**************************************************************************************************************************/
    
    algn_reg_block reg_block;

    //Analysis implementation ports
    uvm_analysis_imp_in_rx#(md_seq_item_mon, algn_model) port_in_rx;	//for receiving information from RX side
    uvm_analysis_imp_in_tx#(md_seq_item_mon, algn_model) port_in_tx;	//for receiving information from TX side
    
    //Ports 
    uvm_analysis_port#(md_response_t) 		port_out_rx;				//for sending the expected response on the RX interface
    uvm_analysis_port#(md_seq_item_mon) 	port_out_tx;				//for sending the expected response on the TX interface
    uvm_analysis_port#(bit) 				port_out_irq;				//for sending the expected interrupt request
    
    //FIFOs and Queues
    local uvm_tlm_fifo#(md_seq_item_mon) 	rx_fifo;    				//Model of the RX FIFO
    local uvm_tlm_fifo#(md_seq_item_mon) 	tx_fifo;    				//Model of the RX FIFO
    local md_seq_item_mon 					buffer[$];    				//Intermediate buffer containing information ready to be aligned
    
	virtual algn_if algn_vif;
    
    local event tx_complete;
    
    /***************************************************************************************************************************/
    /****************************************************      METHODS      ****************************************************/
    /***************************************************************************************************************************/
        
    extern function new(string name = "", uvm_component parent);
    
    extern function void build_phase(uvm_phase phase);

    //port_in_rx
    extern function void write_in_rx(md_seq_item_mon item_mon);
      
    //Rx Controller
    extern local function md_response_t get_exp_response(md_seq_item_mon item);
    extern local function void inc_cnt_drop( );
    extern local function void set_max_drop();
      
    //Rx FIFO
    extern local function void inc_rx_lvl();
    extern local function void set_rx_fifo_full();
    extern local function void push_to_rx_fifo_nb(md_seq_item_mon item);
    
    //[intermediate] buffer builder
    extern local function void build_buffer_nb();
 
    //[intermediate] buffer
    extern local function void dec_rx_lvl();
    extern local function void set_rx_fifo_empty();
    extern local task pop_from_rx_fifo(ref md_seq_item_mon item); 

    //align
    extern local function void split(int unsigned num_bytes, md_seq_item_mon item, ref md_seq_item_mon items[$]);
    extern local function void align_nb();
      
    //Tx FIFO
    extern local function void inc_tx_lvl();
    extern local function void set_tx_fifo_full();
    extern local task push_to_tx_fifo(md_seq_item_mon item);
      
	//Tx Controller
    extern local function void dec_tx_lvl();
    extern local function void set_tx_fifo_empty();
    extern local task pop_from_tx_fifo(ref md_seq_item_mon item);
    extern local function void tx_ctrl_nb();

    //port_in_tx
    extern function void write_in_tx(md_seq_item_mon item_mon);
          
  endclass: algn_model
      
  /**************************************************************************************************************************/
  /**************************************************    IMPLEMENTATION    **************************************************/
  /**************************************************************************************************************************/

  //new
  //---
      
  function algn_model:: new(string name = "", uvm_component parent);
    super.new(name, parent);  
  endfunction
      
  //build_phase
  //-----------
      
  function void algn_model:: build_phase(uvm_phase phase);
    super.build_phase(phase);

    reg_block = algn_reg_block::type_id::create("reg_block", this);

    reg_block.build();
    reg_block.lock_model();

    port_in_rx   = new("port_in_rx", this);
    port_in_tx   = new("port_in_tx", this);
    port_out_rx  = new("port_out_rx", this);
    port_out_tx  = new("port_out_tx", this);
    port_out_irq = new("port_out_irq", this);
    rx_fifo      = new("rx_fifo", this, 8);
    tx_fifo      = new("tx_fifo", this, 8);

    if( ! uvm_config_db#(virtual algn_if)::get(this, "", "algn_vif", algn_vif) ) begin
      `uvm_error( this.get_full_name, "algn_vif NOT found" )
    end 

    //initialize reg_block.CTRL.SIZE with 1
    //important for align_nb() to work correctly
    assert (reg_block.CTRL.SIZE.predict(1)); 

    build_buffer_nb();
    align_nb();
    tx_ctrl_nb();
  endfunction: build_phase

  //get_exp_response
  //----------------
      
  function md_response_t algn_model:: get_exp_response(md_seq_item_mon item);
    if(item.size == 0) 													return MD_ERR;
    if( ( (`ALGN_DATA_WIDTH / 8) + item.offset ) % item.size != 0 ) 	return MD_ERR;
    if( (item.offset + item.size) > (`ALGN_DATA_WIDTH / 8) ) 			return MD_ERR;

    return MD_OKAY;
  endfunction: get_exp_response
  
  //set_max_drop
  //------------
      
  function void algn_model:: set_max_drop();
    assert (reg_block.IRQ.MAX_DROP.predict(1));

    `uvm_info("DEBUG", $sformatf("Drop counter reached max value - %0s: %0d",
                                 reg_block.IRQ.MAX_DROP.get_full_name(),
                                 reg_block.IRQ.MAX_DROP.get_mirrored_value()), UVM_NONE)

    if(reg_block.IRQEN.MAX_DROP.get_mirrored_value() == 1) begin
      port_out_irq.write(1);
    end
  endfunction: set_max_drop

  //inc_cnt_drop
  //------------
      
  function void algn_model:: inc_cnt_drop( );
    //Maximum value to be stored in STATUS.CNT_DROP is 255
    if(reg_block.STATUS.CNT_DROP.get_mirrored_value() < 255) begin
      void'(reg_block.STATUS.CNT_DROP.predict(reg_block.STATUS.CNT_DROP.get_mirrored_value() + 1));

      `uvm_info("DEBUG", $sformatf("Increment %0s: %0d bcz an error is detected",
                                   reg_block.STATUS.CNT_DROP.get_full_name(),
                                   reg_block.STATUS.CNT_DROP.get_mirrored_value) ,
                                   UVM_NONE)

      if(reg_block.STATUS.CNT_DROP.get_mirrored_value() == 255) begin
        set_max_drop();
      end
    end
  endfunction: inc_cnt_drop

  //set_rx_fifo_full
  //----------------
      
  function void algn_model:: set_rx_fifo_full();
    assert (reg_block.IRQ.RX_FIFO_FULL.predict(1));

    `uvm_info("DEBUG", $sformatf("RX FIFO became full - %0s: %0d",
                                 reg_block.IRQ.RX_FIFO_FULL.get_full_name(),
                                 reg_block.IRQ.RX_FIFO_FULL.get_mirrored_value()), UVM_NONE)

    if(reg_block.IRQEN.RX_FIFO_FULL.get_mirrored_value() == 1) begin
      port_out_irq.write(1);
    end
  endfunction: set_rx_fifo_full

  //inc_rx_lvl
  //----------
      
  function void algn_model:: inc_rx_lvl();
    assert (reg_block.STATUS.RX_LVL.predict(reg_block.STATUS.RX_LVL.get_mirrored_value() + 1));

    if(reg_block.STATUS.RX_LVL.get_mirrored_value() == rx_fifo.size()) begin
      set_rx_fifo_full();
    end
  endfunction: inc_rx_lvl

  //push_to_rx_fifo_nb
  //------------------
      
  function void algn_model:: push_to_rx_fifo_nb(md_seq_item_mon item);
    fork 
      begin
      rx_fifo.put(item);

      inc_rx_lvl();

      `uvm_info("DEBUG", $sformatf("RX FIFO push - new level: %0d, pushed entry: %0s",
                                   reg_block.STATUS.RX_LVL.get_mirrored_value(),
                                   item.convert2string()), UVM_NONE)

      port_out_rx.write(MD_OKAY);
      end
    join_none
  endfunction: push_to_rx_fifo_nb

  //set_rx_fifo_empty
  //-----------------

  function void algn_model:: set_rx_fifo_empty();
    assert (reg_block.IRQ.RX_FIFO_EMPTY.predict(1));

    `uvm_info("DEBUG", $sformatf("RX FIFO became empty - %0s: %0d",
                                 reg_block.IRQ.RX_FIFO_EMPTY.get_full_name(),
                                 reg_block.IRQ.RX_FIFO_EMPTY.get_mirrored_value()), UVM_NONE)

    if(reg_block.IRQEN.RX_FIFO_EMPTY.get_mirrored_value() == 1) begin
      port_out_irq.write(1);
    end
  endfunction: set_rx_fifo_empty

  //dec_rx_lvl
  //----------

  function void algn_model:: dec_rx_lvl();
    assert (reg_block.STATUS.RX_LVL.predict(reg_block.STATUS.RX_LVL.get_mirrored_value() - 1));

    if(reg_block.STATUS.RX_LVL.get_mirrored_value() == 0) begin
      set_rx_fifo_empty();
    end
  endfunction: dec_rx_lvl

  //pop_from_rx_fifo
  //----------------

  task algn_model:: pop_from_rx_fifo(ref md_seq_item_mon item);
    rx_fifo.get(item);

    dec_rx_lvl();

    `uvm_info("DEBUG", $sformatf("RX FIFO pop - new level: %0d, popped entry: %0s",
                                 reg_block.STATUS.RX_LVL.get_mirrored_value(),
                                 item.convert2string()), UVM_NONE)
  endtask: pop_from_rx_fifo

  //build_buffer_nb
  //---------------

  function void algn_model:: build_buffer_nb(); 
    int unsigned 		ctrl_size;
    md_seq_item_mon 	rx_item;

    fork
      forever begin
        ctrl_size = reg_block.CTRL.SIZE.get_mirrored_value();

        if( (buffer.sum() with (item.size) ) <= ctrl_size) begin
              pop_from_rx_fifo(rx_item);
              buffer.push_back(rx_item);
        end
        else 	@(posedge algn_vif.clk);
      end
    join_none
  endfunction: build_buffer_nb

  //set_tx_fifo_full
  //----------------

  function void algn_model:: set_tx_fifo_full();
    assert (reg_block.IRQ.TX_FIFO_FULL.predict(1));

    `uvm_info("DEBUG", $sformatf("TX FIFO became full - %0s: %0d",
                                 reg_block.IRQ.TX_FIFO_FULL.get_full_name(),
                                 reg_block.IRQ.TX_FIFO_FULL.get_mirrored_value()), UVM_NONE)

    if(reg_block.IRQEN.TX_FIFO_FULL.get_mirrored_value() == 1) begin
      port_out_irq.write(1);
    end
  endfunction: set_tx_fifo_full

  //inc_tx_lvl
  //----------

  function void algn_model:: inc_tx_lvl();
    assert (reg_block.STATUS.TX_LVL.predict(reg_block.STATUS.TX_LVL.get_mirrored_value() + 1));

    if(reg_block.STATUS.TX_LVL.get_mirrored_value() == tx_fifo.size()) begin
      set_tx_fifo_full();
    end
  endfunction: inc_tx_lvl

  //push_to_tx_fifo
  //---------------

  task algn_model:: push_to_tx_fifo(md_seq_item_mon item);
    tx_fifo.put(item);

    inc_tx_lvl();

    `uvm_info("DEBUG", $sformatf("TX FIFO push - new level: %0d, pushed entry: %0s",
                                 reg_block.STATUS.TX_LVL.get_mirrored_value(),
                                 item.convert2string()), UVM_NONE)
  endtask: push_to_tx_fifo

  //split
  //-----

  function void algn_model:: split(int unsigned num_bytes, md_seq_item_mon item, ref md_seq_item_mon items[$]);
    if( (num_bytes == 0) || (num_bytes >= item.size) ) begin
        `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Can NOT split this item. num_bytes == %0d and item.size() == %0d", num_bytes, item.size) )
    end 

    //splitted_item_1
    begin: splitted_item_1 
      md_seq_item_mon splitted_item_1 = md_seq_item_mon::type_id::create("splitted_item_1", this);   

      splitted_item_1.prev_item_delay = item.prev_item_delay;
      splitted_item_1.length          = item.length;
      splitted_item_1.response        = item.response;
      void'(splitted_item_1.begin_tr(item.get_begin_time()));
      splitted_item_1.end_tr(item.get_end_time());

      splitted_item_1.size = num_bytes;
      splitted_item_1.offset = item.offset;
      for(int i = (item.offset*8); i <= (item.offset*8) + (num_bytes*8 -1) ; i++)
        splitted_item_1.data[i] = item.data[i];

      items.push_back(splitted_item_1);
    end:  splitted_item_1

    //splitted_item_2
    begin: splitted_item_2 
      md_seq_item_mon splitted_item_2 = md_seq_item_mon::type_id::create("splitted_item_2", this);

      splitted_item_2.prev_item_delay = item.prev_item_delay;
      splitted_item_2.length          = item.length;
      splitted_item_2.response        = item.response;
      void'(splitted_item_2.begin_tr(item.get_begin_time()));
      splitted_item_2.end_tr(item.get_end_time());

      splitted_item_2.size = item.size - num_bytes;
      splitted_item_2.offset = item.offset + num_bytes;
      for(int i= (item.offset*8) + (num_bytes*8); i <= `ALGN_DATA_WIDTH - 1; i++)
        splitted_item_2.data[i] = item.data[i];

      items.push_back(splitted_item_2);
    end:  splitted_item_2

  endfunction: split

  //align_nb
  //--------

  function void algn_model:: align_nb();
    fork: fork_join_none
      forever begin: forever_loop
        int unsigned ctrl_size 	 = reg_block.CTRL.SIZE.get_mirrored_value();
        int unsigned ctrl_offset = reg_block.CTRL.OFFSET.get_mirrored_value();

        #1step;
        /*
        #1step delays the following logic a little bit after the positive edge of the clock.
        Why? To give time to build_buffer() to push data in the intermediate buffer. 
        So, at a certain positive edge of the clock, 
        firstly, build_buffer() will push data in the intermediate buffer, and then, 
        after #1step, align() will pop that information from the buffer.
        */

        if( ctrl_size > (buffer.sum() with (item.size)) ) 	@(posedge algn_vif.clk);

        else	// if( ctrl_size <= (buffer.sum() with (item.size)) ), you are ready to align! ENTER the outer_while!

        while( ctrl_size <= (buffer.sum() with (item.size))) begin: outer_while
          md_seq_item_mon tx_item = md_seq_item_mon::type_id::create("tx_item", this);

          tx_item.offset = ctrl_offset;
          void'(tx_item.begin_tr(buffer[0].get_begin_time()));

          while(tx_item.size != ctrl_size) begin: inner_while
            md_seq_item_mon buffer_item = buffer.pop_front();
            /*
            $display("inner_while::");
            $display("     tx_item.size = %0d, tx_item.offset = %0d, ctrl_size = %0d", tx_item.size, tx_item.offset, ctrl_size);
            */
            if(tx_item.size + buffer_item.size <= ctrl_size) 
            begin: NO_need_to_split
                for( int i = 0; i <= (buffer_item.size*8 - 1); i++) 
                     tx_item.data[i + tx_item.offset*8 ] = buffer_item.data[i + buffer_item.offset*8];
                tx_item.size += buffer_item.size;
                /*
                $display("NO_need_to_split::");
                $display("     tx_item.size = %0d, buffer_item.size = %0d, ctrl_size = %0d", tx_item.size, buffer_item.size, ctrl_size);
                $display("     tx_item.data = %h, buffer_item.data = %h", tx_item.data, buffer_item.data);
                */
                  if(tx_item.size == ctrl_size) begin
                    tx_item.end_tr(buffer_item.get_end_time());
                    push_to_tx_fifo(tx_item);
                  end
            end: NO_need_to_split 

            else	 //	if( tx_item.size + buffer_item.size > ctrl_size )
            begin: NEED_to_split
                int unsigned num_bytes_needed = ctrl_size - tx_item.size;
                md_seq_item_mon splitted_items[$];

                split(num_bytes_needed, buffer_item, splitted_items);

                buffer.push_front(splitted_items[1]);
                buffer.push_front(splitted_items[0]);
                /*
                $display("NEED_to_split::"); 
                $display("     tx_item.size = %0d, buffer_item.size = %0d, ctrl_size = %0d", tx_item.size, buffer_item.size, ctrl_size);
                $display("     buffer_item.size = %0d, buffer_item.offset = %0d, buffer_item.data = %h", buffer_item.size, buffer_item.offset, buffer_item.data);
                $display("     splitted_items[0].size = %0d, splitted_items[0].data = %h", splitted_items[0].size, splitted_items[0].data);
                $display("     splitted_items[1].size = %0d, splitted_items[1].data = %h", splitted_items[1].size, splitted_items[1].data);
                */
            end: NEED_to_split
          end: inner_while
        end: outer_while
      end: forever_loop 
    join_none: fork_join_none
  endfunction: align_nb

  //set_tx_fifo_empty
  //-----------------

  function void algn_model:: set_tx_fifo_empty();
    assert (reg_block.IRQ.TX_FIFO_EMPTY.predict(1));

    `uvm_info("DEBUG", $sformatf("TX FIFO became empty - %0s: %0d",
                                 reg_block.IRQ.TX_FIFO_EMPTY.get_full_name(),
                                 reg_block.IRQ.TX_FIFO_EMPTY.get_mirrored_value()), UVM_NONE)

    if(reg_block.IRQEN.TX_FIFO_EMPTY.get_mirrored_value() == 1) begin
      port_out_irq.write(1);
    end
  endfunction: set_tx_fifo_empty

  //dec_tx_lvl
  //----------

  function void algn_model:: dec_tx_lvl();
    assert (reg_block.STATUS.TX_LVL.predict(reg_block.STATUS.TX_LVL.get_mirrored_value() - 1));

    if(reg_block.STATUS.TX_LVL.get_mirrored_value() == 0) begin
      set_tx_fifo_empty();
    end
  endfunction: dec_tx_lvl

  //pop_from_tx_fifo
  //----------------
      
  task algn_model:: pop_from_tx_fifo(ref md_seq_item_mon item);
    tx_fifo.get(item);

    dec_tx_lvl();

    `uvm_info("DEBUG", $sformatf("TX FIFO pop - new level: %0d, poped entry: %0s",
                                 reg_block.STATUS.TX_LVL.get_mirrored_value(),
                                 item.convert2string()), UVM_NONE)
  endtask: pop_from_tx_fifo

  //tx_ctrl_nb
  //----------

  function void algn_model:: tx_ctrl_nb();
    md_seq_item_mon item;
    fork
      forever begin
        pop_from_tx_fifo(item);

        port_out_tx.write(item);

        @ (tx_complete);
      end
    join_none
  endfunction: tx_ctrl_nb

  //write_in_rx
  //-----------
      
  function void algn_model:: write_in_rx(md_seq_item_mon item_mon);
    case( get_exp_response(item_mon) )
        MD_ERR : begin
          inc_cnt_drop();
          port_out_rx.write(MD_ERR);
        end
        MD_OKAY : begin
          push_to_rx_fifo_nb(item_mon);
        end
        default : begin
          `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Un-supported value for response: %0d", get_exp_response(item_mon)))
        end
    endcase
  endfunction: write_in_rx

  //write_in_tx
  //-----------
      
  function void algn_model:: write_in_tx(md_seq_item_mon item_mon);
      -> tx_complete;
  endfunction: write_in_tx

`endif //ALGN_MODEL_SV