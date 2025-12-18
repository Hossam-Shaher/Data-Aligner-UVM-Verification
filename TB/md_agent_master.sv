`ifndef MD_AGENT_MASTER_SV
  `define MD_AGENT_MASTER_SV

  typedef class md_agent_config_master;
  typedef class md_driver_master; 
  typedef class md_sequencer_master;
  typedef class md_monitor;
  typedef class md_seq_item_mon;

  class md_agent_master extends uvm_agent;
    `uvm_component_utils(md_agent_master)

    md_agent_config_master 	m_md_agent_config_master;
    md_driver_master 		m_md_driver_master;
    md_sequencer_master		m_md_sequencer_master;
    md_monitor				m_md_monitor;
    uvm_analysis_port#(md_seq_item_mon)	ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new 

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_md_agent_config_master = md_agent_config_master::type_id::create("m_md_agent_config_master", this);
      if( ! uvm_config_db#(md_agent_config_master)::get(this, "", "m_md_agent_config_master", m_md_agent_config_master) ) begin
        `uvm_error(this.get_full_name(), "m_md_agent_config_master NOT found");
      end    
      if ( m_md_agent_config_master.md_vif == null ) begin
        `uvm_error(this.get_full_name(), "m_md_agent_config_master.apb_vif == null")
      end

      if ( get_is_active() == UVM_ACTIVE) begin
        m_md_driver_master = md_driver_master::type_id::create("m_md_driver_master", this);
        m_md_sequencer_master = md_sequencer_master::type_id::create("m_md_sequencer_master", this); 

        uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::set(this, "m_md_driver_master", "md_rx_vif", m_md_agent_config_master.md_vif);

        m_md_sequencer_master.set_arbitration(m_md_agent_config_master.arb_mode);
      end

      m_md_monitor = md_monitor::type_id::create("m_md_monitor", this);
      uvm_config_db#(virtual md_if#(`ALGN_DATA_WIDTH ))::set(this, "m_md_monitor", "md_vif", m_md_agent_config_master.md_vif);

      m_md_monitor.enable_checks = m_md_agent_config_master.enable_checks ;
      m_md_monitor.stuck_threshold = m_md_agent_config_master.stuck_threshold ;

      ap = new("ap", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
      if ( get_is_active() == UVM_ACTIVE) begin
          m_md_driver_master.seq_item_port.connect(m_md_sequencer_master.seq_item_export);
      end
      m_md_monitor.ap.connect(ap);
    endfunction: connect_phase

    function uvm_active_passive_enum get_is_active();
      return uvm_active_passive_enum'(m_md_agent_config_master.is_active);
    endfunction: get_is_active

  endclass: md_agent_master

`endif  //MD_AGENT_MASTER_SV