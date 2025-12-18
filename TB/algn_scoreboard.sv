`ifndef ALGN_SCOREBOARD_SV
  `define ALGN_SCOREBOARD_SV

  typedef class md_seq_item_mon;

  class algn_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(algn_scoreboard)
    
    //RX information
    uvm_analysis_export#( md_response_t ) 		export_in_model_rx;		    
    uvm_tlm_analysis_fifo#( md_response_t ) 	expected_rx_transactions_fifo;
    uvm_analysis_export#( md_seq_item_mon ) 	export_in_agent_rx;    		
    uvm_tlm_analysis_fifo#( md_seq_item_mon )	actual_rx_transactions_fifo;

    //TX information
    uvm_analysis_export#( md_seq_item_mon ) 	export_in_model_tx;    
    uvm_tlm_analysis_fifo#( md_seq_item_mon ) 	expected_tx_transactions_fifo;
    uvm_analysis_export#( md_seq_item_mon ) 	export_in_agent_tx;
    uvm_tlm_analysis_fifo#( md_seq_item_mon )	actual_tx_transactions_fifo;
    
    //IRQ information
    uvm_analysis_export#(bit) 		export_in_model_irq;
    uvm_tlm_analysis_fifo#(bit) 	expected_irq_transactions_fifo;
    uvm_analysis_export#(bit) 		export_in_monitor_irq;
    uvm_tlm_analysis_fifo#(bit)		actual_irq_transactions_fifo;
    
    //Counters used in report_phase
    int unsigned		mismatch_count = 0;
    int unsigned		leftovers_count = 0;
        
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    extern function void build_phase (uvm_phase phase);

    extern function void connect_phase (uvm_phase phase);

    extern task run_phase (uvm_phase phase);

   	extern function void check_phase (uvm_phase phase);

    extern function void report_phase (uvm_phase phase);
    
  endclass: algn_scoreboard
      
  //build_phase
  function void algn_scoreboard:: build_phase (uvm_phase phase);
    super.build_phase(phase);

    export_in_model_rx  	= new("export_in_model_rx",  	this);
    export_in_model_tx  	= new("export_in_model_tx",  	this);
    export_in_model_irq 	= new("export_in_model_irq", 	this);
    export_in_agent_rx  	= new("export_in_agent_rx",  	this);
    export_in_agent_tx  	= new("export_in_agent_tx",  	this);
    export_in_monitor_irq 	= new("export_in_monitor_irq",  this);

    expected_rx_transactions_fifo  	= new("expected_rx_transactions_fifo",  	this);
    expected_tx_transactions_fifo  	= new("expected_tx_transactions_fifo",  	this);
    expected_irq_transactions_fifo 	= new("expected_irq_transactions_fifo",  	this);
    actual_rx_transactions_fifo 	= new("actual_rx_transactions_fifo",  		this);
    actual_tx_transactions_fifo 	= new("actual_tx_transactions_fifo",  		this);
    actual_irq_transactions_fifo	= new("actual_irq_transactions_fifo",  		this);

  endfunction: build_phase

  //connect_phase
  function void algn_scoreboard:: connect_phase (uvm_phase phase);

    export_in_model_rx.connect(	expected_rx_transactions_fifo.analysis_export	);
    export_in_agent_rx.connect(	actual_rx_transactions_fifo.analysis_export		);

    export_in_model_tx.connect(	expected_tx_transactions_fifo.analysis_export	);
    export_in_agent_tx.connect(	actual_tx_transactions_fifo.analysis_export		);

    export_in_model_irq.connect(	expected_irq_transactions_fifo.analysis_export	);
    export_in_monitor_irq.connect( 	actual_irq_transactions_fifo.analysis_export	);

  endfunction: connect_phase

  //run_phase
  task algn_scoreboard:: run_phase (uvm_phase phase);
    md_response_t    expected_rx_transaction;
    md_seq_item_mon  actual_rx_transaction;

    md_seq_item_mon  expected_tx_transaction;
    md_seq_item_mon  actual_tx_transaction;

    bit   expected_irq_transaction;
    bit   actual_irq_transaction;

    fork 
        forever begin: RX_information
           fork
             expected_rx_transactions_fifo.get( expected_rx_transaction );
             actual_rx_transactions_fifo.get(	actual_rx_transaction 	);
           join
           if ( expected_rx_transaction !== actual_rx_transaction.response ) begin
              `uvm_error( this.get_name(), $sformatf("RX_information MISMATCH:: expected_rx_transaction: %s - actual_rx_transaction.response: %s",
                                                  	 expected_rx_transaction.name(), actual_rx_transaction.response.name()) )  
              mismatch_count++;
           end
        end: RX_information

        forever begin: TX_information
             fork
               expected_tx_transactions_fifo.get( expected_tx_transaction );
               actual_tx_transactions_fifo.get(	actual_tx_transaction 	);
             join
             if ( ! expected_tx_transaction.compare(actual_tx_transaction) ) begin
                  `uvm_error( this.get_name(), $sformatf("TX_information MISMATCH:: expected_tx_transaction: %s - actual_tx_transaction: %s",
                                                       	 expected_tx_transaction.convert2string(), actual_tx_transaction.convert2string()) )  
                  mismatch_count++;
             end
        end: TX_information

        forever begin: IRQ_information	
             fork   
                expected_irq_transactions_fifo.get( expected_irq_transaction ); 
                actual_irq_transactions_fifo.get(	actual_irq_transaction 	);
             join
             if ( expected_irq_transaction !== actual_irq_transaction ) begin
                  `uvm_error( this.get_name(), $sformatf("IRQ_information MISMATCH:: expected_irq_transaction: %0d - actual_irq_transaction: %0d",
                                                     	 expected_irq_transaction, actual_irq_transaction ) )  
                  mismatch_count++;
             end
        end: IRQ_information

    join_none

  endtask: run_phase

  //check_phase
  function void algn_scoreboard:: check_phase (uvm_phase phase);
    //Check that no unaccounted-for data remain in the FIFOs
    md_response_t 	response_transaction;
    md_seq_item_mon item_transaction;
    bit 			bit_transaction;

    if ( expected_rx_transactions_fifo.try_get( response_transaction ) ) begin
      `uvm_error( "expected_rx_transactions_fifo", $sformatf("Found a leftover transaction: %s", response_transaction.name() ) )
      leftovers_count++;
    end

    if ( actual_rx_transactions_fifo.try_get( item_transaction ) ) begin
      `uvm_error( "actual_rx_transactions_fifo", $sformatf("Found a leftover transaction: %s", item_transaction.convert2string() ) )
      leftovers_count++;
    end

    if ( expected_tx_transactions_fifo.try_get( item_transaction ) ) begin
      `uvm_error( "expected_tx_transactions_fifo", $sformatf("Found a leftover transaction: %s", item_transaction.convert2string() ) )
      leftovers_count++;
    end

   if ( actual_tx_transactions_fifo.try_get( item_transaction ) ) begin
     `uvm_error( "actual_tx_transactions_fifo", $sformatf("Found a leftover transaction: %s", item_transaction.convert2string() ) )
      leftovers_count++;
   end

   if ( expected_irq_transactions_fifo.try_get( bit_transaction ) ) begin
     `uvm_error( "expected_irq_transactions_fifo", $sformatf("Found a leftover transaction: %0d", bit_transaction ) )
     leftovers_count++;
   end     

   if ( actual_irq_transactions_fifo.try_get( bit_transaction ) ) begin
     `uvm_error( "actual_irq_transactions_fifo", $sformatf("Found a leftover transaction: %0d", bit_transaction ) )
     leftovers_count++;
   end       

  endfunction: check_phase

  function void algn_scoreboard:: report_phase (uvm_phase phase);
    if( mismatch_count == 0) begin 
      `uvm_info("SCOREBOARD RESULTS", $sformatf("Mismatches:: PASS; no mismatches") , UVM_NONE)
    end
    else begin
      `uvm_error("SCOREBOARD RESULTS", $sformatf("Mismatches:: ERR; number of mismatches: %0d", mismatch_count))
    end

    if( leftovers_count == 0) begin 
      `uvm_info("SCOREBOARD RESULTS", $sformatf("Leftovers:: PASS; no leftovers") , UVM_NONE)
    end
    else begin
      `uvm_error("SCOREBOARD RESULTS", $sformatf("Leftovers:: ERR; number of leftovers (at least): %0d", leftovers_count) )
    end

  endfunction: report_phase

`endif //ALGN_SCOREBOARD_SV