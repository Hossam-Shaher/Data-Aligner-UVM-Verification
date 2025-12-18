`ifndef ALGN_ENV_CONFIG_SV
  `define ALGN_ENV_CONFIG_SV

  typedef class apb_agent_config;
  typedef class md_agent_config_master;
  typedef class md_agent_config_slave;

  class algn_env_config extends uvm_object;
    `uvm_object_utils(algn_env_config)

    apb_agent_config		m_apb_agent_config;
    md_agent_config_master	m_md_agent_config_master;
    md_agent_config_slave	m_md_agent_config_slave;

    bit coverage_enable_apb = 1;			//if this field == 1, apb_coverage_collector will be instantiated in the env 
    bit coverage_enable_md_master = 1;
    bit coverage_enable_md_slave = 1;

    virtual algn_if algn_vif;

    function new(string name="");
      super.new(name);

      m_apb_agent_config 		= apb_agent_config::type_id::create("m_apb_agent_config");
      m_md_agent_config_master	= md_agent_config_master::type_id::create("md_agent_config_master");
      m_md_agent_config_slave	= md_agent_config_slave::type_id::create("md_agent_config_slave");

    endfunction: new   

  endclass: algn_env_config

`endif  //ALGN_ENV_CONFIG_SV