`ifndef ALGN_ENV_SV
  `define ALGN_ENV_SV

  typedef class algn_env_config;
  typedef class apb_agent;
  typedef class apb_coverage_collector;
  typedef class md_agent_master;
  typedef class md_agent_slave;
  typedef class md_coverage_collector;
  typedef class algn_model;  
  typedef class apb_reg_adapter;
  typedef class algn_scoreboard;
  typedef class irq_monitor;

  class algn_env extends uvm_env;

    `uvm_component_utils(algn_env)

    algn_env_config 			m_algn_env_config;
    apb_agent 					m_apb_agent;
    apb_coverage_collector 		m_apb_coverage_collector;
    md_agent_master				m_md_agent_master;
    md_agent_slave				m_md_agent_slave;
    md_coverage_collector		m_md_coverage_collector_master,
                              	m_md_coverage_collector_slave;
    algn_model 					model;
    apb_reg_adapter				adapter;
    uvm_reg_predictor#(apb_seq_item_mon) 	predictor;
    algn_scoreboard				m_algn_scoreboard;
    irq_monitor					m_irq_monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);

    extern function void connect_phase(uvm_phase phase);

  endclass: algn_env

  //build_phase

  function void algn_env:: build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_algn_env_config = algn_env_config::type_id::create("m_algn_env_config", this);
    if( ! uvm_config_db#(algn_env_config)::get(this, "", "m_algn_env_config", m_algn_env_config) ) begin
      `uvm_error(this.get_full_name(), "m_algn_env_config NOT found");
    end    
    // manipulate properties of m_algn_env_config HERE

    m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
    if( m_algn_env_config.coverage_enable_apb == 1 )
        m_apb_coverage_collector =	apb_coverage_collector::type_id::create("m_apb_coverage_collector", this);

    m_md_agent_master = md_agent_master::type_id::create("m_md_agent_master", this);
    if( m_algn_env_config.coverage_enable_md_master == 1 )
        m_md_coverage_collector_master = md_coverage_collector::type_id::create("m_md_coverage_collector_master", this);

    m_md_agent_slave = md_agent_slave::type_id::create("m_md_agent_slave", this);
    if( m_algn_env_config.coverage_enable_md_slave == 1 )
        m_md_coverage_collector_slave = md_coverage_collector::type_id::create("m_md_coverage_collector_slave", this);

    uvm_config_db#(apb_agent_config)::set(this, "m_apb_agent", "m_apb_agent_config", m_algn_env_config.m_apb_agent_config);
    uvm_config_db#(md_agent_config_slave)::set(this, "m_md_agent_slave", "m_md_agent_config_slave", m_algn_env_config.m_md_agent_config_slave);
    uvm_config_db#(md_agent_config_master)::set(this, "m_md_agent_master", "m_md_agent_config_master", m_algn_env_config.m_md_agent_config_master);
    if ( m_algn_env_config.algn_vif == null ) begin
      `uvm_error(this.get_full_name(), "m_algn_env_config.algn_vif == null")
    end
    uvm_config_db#(virtual algn_if):: set(this, "model"			, "algn_vif", m_algn_env_config.algn_vif);
    uvm_config_db#(virtual algn_if):: set(this, "m_irq_monitor"	, "algn_vif", m_algn_env_config.algn_vif);

    model = algn_model::type_id::create("model", this);
    adapter = apb_reg_adapter::type_id::create("adapter", this);
    predictor = uvm_reg_predictor#(apb_seq_item_mon)::type_id::create("predictor", this);
    //predictor.set_report_verbosity_level(UVM_HIGH);		//To print REG_PREDICT reports

    m_algn_scoreboard = algn_scoreboard::type_id::create("m_algn_scoreboard", this);
    m_irq_monitor = irq_monitor::type_id::create("m_irq_monitor", this);
  endfunction: build_phase 

  //connect_phase

  function void algn_env:: connect_phase(uvm_phase phase);
    if( m_algn_env_config.coverage_enable_apb == 1 )
        m_apb_agent.ap.connect(m_apb_coverage_collector.analysis_export);

    if( m_algn_env_config.coverage_enable_md_master == 1 )
        m_md_agent_master.ap.connect(m_md_coverage_collector_master.analysis_export);

    if( m_algn_env_config.coverage_enable_md_slave == 1 )
        m_md_agent_slave.ap.connect(m_md_coverage_collector_slave.analysis_export);

    model.reg_block.default_map.set_sequencer(m_apb_agent.m_apb_sequencer, adapter);
    predictor.map     = model.reg_block.default_map;
    predictor.adapter = adapter;
    m_apb_agent.ap.connect(predictor.bus_in);

    m_md_agent_master.ap.connect(model.port_in_rx);
    m_md_agent_slave.ap.connect(model.port_in_tx);

    model.port_out_rx.connect(m_algn_scoreboard.export_in_model_rx);
    model.port_out_tx.connect(m_algn_scoreboard.export_in_model_tx);
    model.port_out_irq.connect(m_algn_scoreboard.export_in_model_irq);
    m_md_agent_master.ap.connect(m_algn_scoreboard.export_in_agent_rx);
    m_md_agent_slave.ap.connect(m_algn_scoreboard.export_in_agent_tx);
    m_irq_monitor.ap.connect(m_algn_scoreboard.export_in_monitor_irq);

    m_apb_coverage_collector.reg_block = model.reg_block;

  endfunction: connect_phase 
    
`endif //ALGN_ENV_SV