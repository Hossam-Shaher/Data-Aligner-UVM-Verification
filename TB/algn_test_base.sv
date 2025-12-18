`ifndef ALGN_TEST_BASE_SV
  `define ALGN_TEST_BASE_SV

  typedef class algn_env;
  typedef class algn_env_config;

  class algn_test_base extends uvm_test;

    `uvm_component_utils(algn_test_base)

    algn_env 		m_algn_env;
    algn_env_config	m_algn_env_config;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_algn_env 		= algn_env::type_id::create("m_algn_env", this); 
      m_algn_env_config = algn_env_config::type_id::create("m_algn_env_config", this);  

      if( ! uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", m_algn_env_config.m_apb_agent_config.apb_vif) ) begin
        `uvm_error(this.get_full_name(), "apb_vif NOT found");
      end

      if( ! uvm_config_db#(virtual md_if#(32))::get(this, "", "md_rx_vif", m_algn_env_config.m_md_agent_config_master.md_vif) ) begin
        `uvm_error(this.get_full_name(), "md_vif (rx) NOT found");
      end

      if( ! uvm_config_db#(virtual md_if#(32))::get(this, "", "md_tx_vif", m_algn_env_config.m_md_agent_config_slave.md_vif) ) begin
        `uvm_error(this.get_full_name(), "md_vif (tx) NOT found");
      end

      if( ! uvm_config_db#(virtual algn_if)::get(this, "", "algn_vif", m_algn_env_config.algn_vif) ) begin
        `uvm_error(this.get_full_name(), "algn_vif NOT found");
      end

      uvm_config_db#(algn_env_config)::set(this, "m_algn_env", "m_algn_env_config", m_algn_env_config);

    endfunction: build_phase 

  endclass: algn_test_base

`endif //ALGN_TEST_BASE_SV