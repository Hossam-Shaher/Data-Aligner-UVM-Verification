`ifndef ALGN_TEST_RANDOM_SV
  `define ALGN_TEST_RANDOM_SV

  typedef class algn_test_base;
  typedef class md_sequence_master;
  typedef class md_sequence_slave;
  typedef class algn_sequence_config_reg;
  typedef class algn_sequence_status_reg;

  class algn_test_random extends algn_test_base;

    `uvm_component_utils(algn_test_random)

    md_sequence_master 			m_md_sequence_master;
    md_sequence_slave			m_md_sequence_slave;
    algn_sequence_config_reg	m_algn_sequence_config_reg;
    algn_sequence_status_reg	m_algn_sequence_status_reg;

    //Number of MD RX (master) transactions (used in a "repeat")
    protected int unsigned num_md_rx_transactions = 20;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // manipulate properties of m_algn_env_config HERE
      m_md_sequence_master 			= md_sequence_master::type_id::create("m_md_sequence_master", this);
      m_md_sequence_slave			= md_sequence_slave::type_id::create("m_md_sequence_slave", this);
      m_algn_sequence_config_reg 	= algn_sequence_config_reg::type_id::create("m_algn_sequence_config_reg", this);
      m_algn_sequence_status_reg 	= algn_sequence_status_reg::type_id::create("m_algn_sequence_status_reg", this);
    endfunction: build_phase 

    task run_phase (uvm_phase phase);
      uvm_status_e status;

      phase.raise_objection(this, "algn_test_random", 1);
      #100ns;

      //////////////////////
      //m_md_sequence_slave
      //////////////////////

      fork
          begin
              m_md_sequence_slave.start(m_algn_env.m_md_agent_slave.m_md_sequencer_slave);
          end
      join_none

      //See tutorial #156 for more complicated test.

      /////////////////////////////
      //m_algn_sequence_config_reg
      /////////////////////////////

      m_algn_sequence_config_reg.reg_block = m_algn_env.model.reg_block;
      assert( m_algn_sequence_config_reg.randomize() );
      m_algn_sequence_config_reg.start(null);

      ///////////////////////
      //m_md_sequence_master
      ///////////////////////

      repeat(num_md_rx_transactions) begin
          assert( m_md_sequence_master.randomize() );
          m_md_sequence_master.start(m_algn_env.m_md_agent_master.m_md_sequencer_master);
      end

      /////////////////////////////
      //m_algn_sequence_status_reg
      /////////////////////////////

      #500;
      m_algn_sequence_status_reg.reg_block = m_algn_env.model.reg_block;
      assert( m_algn_sequence_status_reg.randomize() );
      m_algn_sequence_status_reg.start(null);

      #500
      phase.drop_objection(this, "algn_test_random", 1);

    endtask: run_phase

  endclass: algn_test_random

`endif //ALGN_TEST_RANDOM_SV