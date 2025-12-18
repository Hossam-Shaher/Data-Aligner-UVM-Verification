`ifndef ALGN_PKG_SV
  `define ALGN_PKG_SV

  //Timescale
  `timescale 1ns/1ns

  //Macros
  `define ALGN_DATA_WIDTH 32
  `define FIFO_DEPTH 8

  //Interfaces
  `include "md_if.sv"
  `include "apb_if.sv"
  `include "algn_if.sv"

  package algn_pkg;
      //UVM
      `include "uvm_macros.svh"
      import uvm_pkg::*;

      //Globals (types, enumerations, ...)
      `include "algn_globals.sv"

      //RAL
      `include "algn_reg_ctrl.sv"
      `include "algn_reg_status.sv"
      `include "algn_reg_irqen.sv"
      `include "algn_reg_irq.sv"
      `include "algn_reg_block.sv"
      `include "apb_reg_adapter.sv"

      //Modeling & Checking
      `include "algn_model.sv"
      `include "algn_scoreboard.sv"

      //MD Rx (master) and Tx (slave)
      `include "md_seq_item_base.sv"
      `include "md_seq_item_mon.sv"
      `include "md_seq_item_drv.sv"		//includes: md_seq_item_drv_*

      `include "md_monitor.sv"
      `include "md_driver_master.sv"
      `include "md_driver_slave.sv"
      `include "md_sequencer.sv"		//includes: md_sequencer_* 

      `include "md_agent_config.sv"		//includes: md_agent_config_*
      `include "md_agent_master.sv"
      `include "md_agent_slave.sv"
      `include "md_coverage_collector.sv"

      //APB
      `include "apb_seq_item_base.sv"
      `include "apb_seq_item_drv.sv"
      `include "apb_seq_item_mon.sv"

      `include "apb_monitor.sv"
      `include "apb_driver.sv"
      `include "apb_sequencer.sv"

      `include "apb_agent_config.sv"
      `include "apb_agent.sv"
      `include "apb_coverage_collector.sv"

      //irq_monitor
      `include "irq_monitor.sv"

      //Environment
      `include "algn_env_config.sv"
      `include "algn_env.sv"

      //Sequences
      `include "md_sequence_master.sv"
      `include "md_sequence_slave.sv"
      `include "md_sequence_master_err.sv"
      `include "algn_sequence_reg_access.sv"
      `include "algn_sequence_config_reg.sv"
      `include "algn_sequence_status_reg.sv"

      //Tests
      `include "algn_test_base.sv"
      `include "algn_test_reg_access.sv"
      `include "algn_test_random.sv"
      `include "algn_test_illegal_rx.sv"

  endpackage: algn_pkg 

`endif //ALGN_PKG_SV