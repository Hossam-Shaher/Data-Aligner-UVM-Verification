`ifndef APB_AGENT_SV
  `define APB_AGENT_SV

  typedef class apb_agent_config;
  typedef class apb_monitor;
  typedef class apb_driver; 
  typedef class apb_sequencer;
  typedef class apb_seq_item_mon;

  class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_agent_config 	m_apb_agent_config;
    apb_driver 			m_apb_driver;
    apb_sequencer		m_apb_sequencer;
    apb_monitor			m_apb_monitor;
    uvm_analysis_port#(apb_seq_item_mon)	ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new 

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_apb_agent_config = apb_agent_config::type_id::create("m_apb_agent_config", this);
      if( ! uvm_config_db#(apb_agent_config)::get(this, "", "m_apb_agent_config", m_apb_agent_config) ) begin
        `uvm_error(this.get_full_name(), "m_apb_agent_config NOT found");
      end    
      if ( m_apb_agent_config.apb_vif == null ) begin
        `uvm_error(this.get_full_name(), "m_apb_agent_config.apb_vif == null")
      end
      if ( get_is_active() == UVM_ACTIVE) begin
        m_apb_driver = apb_driver::type_id::create("m_apb_driver", this);
        m_apb_sequencer = apb_sequencer::type_id::create("m_apb_sequencer", this); 

        uvm_config_db#(virtual apb_if)::set(this, "m_apb_driver", "apb_vif", m_apb_agent_config.apb_vif);
        m_apb_sequencer.set_arbitration(m_apb_agent_config.arb_mode);
      end

      m_apb_monitor = apb_monitor::type_id::create("m_apb_monitor", this);
      uvm_config_db#(virtual apb_if)::set(this, "m_apb_monitor", "apb_vif", m_apb_agent_config.apb_vif);

      m_apb_monitor.enable_checks = m_apb_agent_config.enable_checks ;
      m_apb_monitor.stuck_threshold = m_apb_agent_config.stuck_threshold ;

      ap = new("ap", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
      if ( get_is_active() == UVM_ACTIVE) begin
          m_apb_driver.seq_item_port.connect(m_apb_sequencer.seq_item_export);
      end
      m_apb_monitor.ap.connect(ap);
    endfunction: connect_phase

    function uvm_active_passive_enum get_is_active();
      return uvm_active_passive_enum'(m_apb_agent_config.is_active);
    endfunction: get_is_active

  endclass: apb_agent

`endif  //APB_AGENT_SV