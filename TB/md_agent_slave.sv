`ifndef MD_AGENT_SLAVE_SV
  `define MD_AGENT_SLAVE_SV

  typedef class md_agent_config_slave;
  typedef class md_driver_slave; 
  typedef class md_sequencer_slave;
  typedef class md_monitor;
  typedef class md_seq_item_mon;

  class md_agent_slave extends uvm_agent;
    `uvm_component_utils(md_agent_slave)

    md_agent_config_slave 	m_md_agent_config_slave;
    md_driver_slave 		m_md_driver_slave;
    md_sequencer_slave		m_md_sequencer_slave;
    md_monitor				m_md_monitor;
    uvm_analysis_port#(md_seq_item_mon)	ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new 

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_md_agent_config_slave = md_agent_config_slave::type_id::create("m_md_agent_config_slave", this);
      if( ! uvm_config_db#(md_agent_config_slave)::get(this, "", "m_md_agent_config_slave", m_md_agent_config_slave) ) begin
        `uvm_error(this.get_full_name(), "m_md_agent_config_slave NOT found");
      end    
      if ( m_md_agent_config_slave.md_vif == null ) begin
        `uvm_error(this.get_full_name(), "m_md_agent_config_slave.apb_vif == null")
      end

      if ( get_is_active() == UVM_ACTIVE) begin
        m_md_driver_slave = md_driver_slave::type_id::create("m_md_driver_slave", this);
        m_md_sequencer_slave = md_sequencer_slave::type_id::create("m_md_sequencer_slave", this); 

        uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::set(this, "m_md_driver_slave", "md_tx_vif", m_md_agent_config_slave.md_vif);

        m_md_sequencer_slave.set_arbitration(m_md_agent_config_slave.arb_mode);
      end

      m_md_monitor = md_monitor::type_id::create("m_md_monitor", this);
      uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::set(this, "m_md_monitor", "md_vif", m_md_agent_config_slave.md_vif);

      m_md_monitor.enable_checks = m_md_agent_config_slave.enable_checks ;
      m_md_monitor.stuck_threshold = m_md_agent_config_slave.stuck_threshold ;

      ap = new("ap", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
      if ( get_is_active() == UVM_ACTIVE) begin
          m_md_driver_slave.seq_item_port.connect(m_md_sequencer_slave.seq_item_export);
      end
      m_md_monitor.ap.connect(ap);
    endfunction: connect_phase

    function uvm_active_passive_enum get_is_active();
      return uvm_active_passive_enum'(m_md_agent_config_slave.is_active);
    endfunction: get_is_active

  endclass: md_agent_slave

`endif  //MD_AGENT_SLAVE_SV