`ifndef MD_AGENT_CONFIG_SV
  `define MD_AGENT_CONFIG_SV

  class md_agent_config_base extends uvm_object;
    `uvm_object_utils(md_agent_config_base)

    virtual md_if#(`ALGN_DATA_WIDTH) 	md_vif;
    uvm_active_passive_enum 			is_active = UVM_ACTIVE;
    uvm_sequencer_arb_mode 				arb_mode = UVM_SEQ_ARB_FIFO;
    bit 								enable_checks = 1;
    //Note: "md_if" has its own "enable_checks"
    //"md_agent_config --> enable_checks" is responsible for the protocol checks of the monitor
    //"md_if --> enable_checks" is responsible for the protocol checks of the interface
    //both can be configured in the test.

    //Number of clock cycles after which an APB transfer is considered stuck
    //and an error is triggered (Protocol check #16)
    int unsigned stuck_threshold = 1000;

    function new(string name="");
      super.new(name);
    endfunction: new   

  endclass: md_agent_config_base

  /************************************************************************************************/

  class md_agent_config_master extends md_agent_config_base;
    `uvm_object_utils(md_agent_config_master)

    function new(string name="");
      super.new(name);
    endfunction: new   

  endclass: md_agent_config_master

  /************************************************************************************************/

  class md_agent_config_slave extends md_agent_config_base;
    `uvm_object_utils(md_agent_config_slave)

    function new(string name="");
      super.new(name);
    endfunction: new   

  endclass: md_agent_config_slave


`endif  //MD_AGENT_CONFIG_SV