`ifndef ALGN_TEST_ILLEGAL_RX_SV
  `define ALGN_TEST_ILLEGAL_RX_SV

  typedef class algn_test_random;

  class algn_test_illegal_rx extends algn_test_random;

    `uvm_component_utils(algn_test_illegal_rx)

    function new(string name, uvm_component parent);
      super.new(name, parent);

      md_sequence_master::type_id::set_type_override(md_sequence_master_err::get_type());
      num_md_rx_transactions = 300;
    endfunction: new

  endclass: algn_test_illegal_rx

`endif //ALGN_TEST_ILLEGAL_RX_SV