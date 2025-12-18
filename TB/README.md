# UVM Testbench
This is a categorized list of SV files used to build this testbench.

**Top module**
* testbench.sv

**Aligner package**
* algn_pkg.sv

**Interfaces**
* md_if.sv
* apb_if.sv
* algn_if.sv

**Globals (types, enumerations, ...)**
* algn_globals.sv

**RAL**
* *Registers*
	* algn_reg_ctrl.sv
	* algn_reg_status.sv
	* algn_reg_irqen.sv
	* algn_reg_irq.sv
* *Register block*
	* algn_reg_block.sv
* *Adapter*
	* apb_reg_adapter.sv

**Model & Scoreboard**
* algn_model.sv
* algn_scoreboard.sv

**MD Rx (master) and Tx (slave)**
* *Sequence item*
	* md_seq_item_base.sv
	* md_seq_item_mon.sv
	* md_seq_item_drv.sv
* *Sequencer, driver, and monitor*
	* md_monitor.sv
	* md_driver_master.sv
	* md_driver_slave.sv
	* md_sequencer.sv		
* *Agent and agent configuration object*
	* md_agent_config.sv		
	* md_agent_master.sv
	* md_agent_slave.sv
* *Coverage collector*
	md_coverage_collector.sv

**APB**
* *Sequence item*
	* apb_seq_item_base.sv
	* apb_seq_item_drv.sv
	* apb_seq_item_mon.sv
* *Sequencer, driver, and monitor*
	* apb_monitor.sv
	* apb_driver.sv
	* apb_sequencer.sv
*	*Agent and agent configuration object*
	* apb_agent_config.sv
	* apb_agent.sv
* *coverage collector*
	* apb_coverage_collector.sv

**irq monitor**
* irq_monitor.sv

**Environment and environment configuration object**
* algn_env_config.sv
* algn_env.sv

**Sequences**
* md_sequence_master.sv
* md_sequence_slave.sv
* md_sequence_master_err.sv
* algn_sequence_reg_access.sv
* algn_sequence_config_reg.sv
* algn_sequence_status_reg.sv

**Tests**
* algn_test_base.sv
* algn_test_reg_access.sv
* algn_test_random.sv
* algn_test_illegal_rx.sv
