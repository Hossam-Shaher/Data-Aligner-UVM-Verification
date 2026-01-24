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

      /** Registers **/
      `include "algn_reg_ctrl.sv"
      `include "algn_reg_status.sv"
      `include "algn_reg_irqen.sv"
      `include "algn_reg_irq.sv"

      /** Register block **/
      `include "algn_reg_block.sv"

      /**  Adapter **/
      `include "apb_reg_adapter.sv"

    //Model & Scoreboard
    `include "algn_model.sv"
    `include "algn_scoreboard.sv"

    //MD Rx (master) and Tx (slave)

      /** Sequence items **/
      `include "md_seq_item_base.sv"
      `include "md_seq_item_mon.sv"
      `include "md_seq_item_drv.sv"		//includes: md_seq_item_drv_*

      /** Sequencer, driver, and monitor **/
      `include "md_monitor.sv"
      `include "md_driver_master.sv"
      `include "md_driver_slave.sv"
      `include "md_sequencer.sv"		//includes: md_sequencer_* 

      /** Agent and agent configuration object **/
      `include "md_agent_config.sv"		//includes: md_agent_config_*
      `include "md_agent_master.sv"
      `include "md_agent_slave.sv"

      /** Coverage collector **/
      `include "md_coverage_collector.sv"

    //APB

      /** Sequence items **/
      `include "apb_seq_item_base.sv"
      `include "apb_seq_item_drv.sv"
      `include "apb_seq_item_mon.sv"

      /** Sequencer, driver, and monitor **/
      `include "apb_monitor.sv"
      `include "apb_driver.sv"
      `include "apb_sequencer.sv"

      /** Agent and agent configuration object **/
      `include "apb_agent_config.sv"
      `include "apb_agent.sv"

      /** Coverage collector **/
      `include "apb_coverage_collector.sv"

    //irq (interrupt request) monitor
    `include "irq_monitor.sv"

    //Environment and environment configuration object
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
