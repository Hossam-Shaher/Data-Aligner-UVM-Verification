`include "algn_pkg.sv"

module tb;
  
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import algn_pkg::*;
  
  //Clock generator
  `define CLK 5ns		//Half cycle
  logic clk = 0;
  always #`CLK clk = ~ clk;
  
  //Interfaces
  apb_if 					apb_if_inst( .pclk(clk) );
  md_if#(`ALGN_DATA_WIDTH) 	md_rx_if( .clk(clk) );
  md_if#(`ALGN_DATA_WIDTH) 	md_tx_if( .clk(clk) );
  algn_if					algn_if_inst( .clk(clk) );
  
  //connecting resets
  assign md_rx_if.reset_n 		= apb_if_inst.preset_n;
  assign md_tx_if.reset_n 		= apb_if_inst.preset_n;
  assign algn_if_inst.reset_n 	= apb_if_inst.preset_n;
  
  //Initial reset generator
  initial begin
    apb_if_inst.preset_n = 1;
    #3ns  apb_if_inst.preset_n = 0;
    #30ns apb_if_inst.preset_n = 1;
  end
  
  //DUT
  cfs_aligner dut(
    .clk(		  clk),
    .reset_n(	  apb_if_inst.preset_n),
  
    .paddr(		  apb_if_inst.paddr),
    .pwrite(	  apb_if_inst.pwrite),
    .psel(		  apb_if_inst.psel),
    .penable(	  apb_if_inst.penable),
    .pwdata(	  apb_if_inst.pwdata),
    .pready(	  apb_if_inst.pready),
    .prdata(	  apb_if_inst.prdata),
    .pslverr(	  apb_if_inst.pslverr),
    
    .md_rx_valid( md_rx_if.valid),
    .md_rx_data(  md_rx_if.data),
    .md_rx_offset(md_rx_if.offset),
    .md_rx_size(  md_rx_if.size),
    .md_rx_ready( md_rx_if.ready),
    .md_rx_err(   md_rx_if.err),
    
    .md_tx_valid( md_tx_if.valid),
    .md_tx_data(  md_tx_if.data),
    .md_tx_offset(md_tx_if.offset),
    .md_tx_size(  md_tx_if.size),
    .md_tx_ready( md_tx_if.ready),
    .md_tx_err(   md_tx_if.err),
    
    .irq(         algn_if_inst.irq)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    uvm_config_db#(virtual apb_if):: set(null, "uvm_test_top", "apb_vif", apb_if_inst);
    uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH))::set(null, "uvm_test_top", "md_rx_vif", md_rx_if);
    uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH))::set(null, "uvm_test_top", "md_tx_vif", md_tx_if);
    uvm_config_db#(virtual algn_if):: set(null, "uvm_test_top", "algn_vif", algn_if_inst);
    
    run_test("algn_test_base"); 
    //Default test is "algn_test_base" 
    //Use +UVM_TESTNAME=<class name> to choose another test
    //Example: +UVM_TESTNAME=algn_test_reg_access
  end
    
endmodule: tb