`ifndef ALGN_TEST_REG_ACCESS_SV
  `define ALGN_TEST_REG_ACCESS_SV

  typedef class algn_test_base;
  typedef class algn_sequence_reg_access;  

  class algn_test_reg_access extends algn_test_base;

    `uvm_component_utils(algn_test_reg_access)

    algn_sequence_reg_access m_algn_sequence_reg_access;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //You can manipulate properties of m_algn_env_config HERE
      m_algn_sequence_reg_access = algn_sequence_reg_access::type_id::create("m_algn_sequence_reg_access", this);
    endfunction: build_phase 

    task run_phase (uvm_phase phase);
      phase.raise_objection(this, "algn_test_reg_access", 1);
      #100ns;

      m_algn_sequence_reg_access.reg_block = m_algn_env.model.reg_block;

      assert ( m_algn_sequence_reg_access.randomize() );

      m_algn_sequence_reg_access.start(null);

      #100ns;
      phase.drop_objection(this, "algn_test_reg_access", 1);
    endtask: run_phase

  endclass: algn_test_reg_access

`endif //ALGN_TEST_REG_ACCESS_SV