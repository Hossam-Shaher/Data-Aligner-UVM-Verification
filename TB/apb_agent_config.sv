`ifndef APB_AGENT_CONFIG_SV
  `define APB_AGENT_CONFIG_SV

  class apb_agent_config extends uvm_object;
    `uvm_object_utils(apb_agent_config)

    virtual apb_if 				apb_vif;
    uvm_active_passive_enum 	is_active = UVM_ACTIVE;
    uvm_sequencer_arb_mode 		arb_mode = UVM_SEQ_ARB_FIFO;
    bit 						enable_checks = 1;
    //Note: "apb_if" has its own "enable_checks"
    //"apb_agent_config --> enable_checks" is responsible for the protocol checks of the monitor
    //"apb_if --> enable_checks" is responsible for the protocol checks of the interface
    //both can be configured in the test.

    //Number of clock cycles after which an APB transfer is considered stuck
    //and an error is triggered (Protocol check #5)
    int unsigned stuck_threshold = 1000;

    function new(string name="");
      super.new(name);
    endfunction: new   

  endclass: apb_agent_config

`endif  //APB_AGENT_CONFIG_SV