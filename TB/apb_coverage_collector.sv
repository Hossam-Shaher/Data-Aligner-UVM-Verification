`ifndef APB_COVERAGE_COLLECTOR_SV
  `define APB_COVERAGE_COLLECTOR_SV

  typedef class apb_seq_item_mon;
  typedef class algn_reg_block;

  class apb_coverage_collector extends uvm_subscriber#(apb_seq_item_mon);
    `uvm_component_utils(apb_coverage_collector)

    apb_seq_item_mon 	item;
    algn_reg_block 		reg_block;
    //One responsibility of this coverage collector is to collect register-level functional coverage
    //so it needs a handle to the register model

    covergroup cover_item;
        option.per_instance = 1;

        direction : coverpoint item.m_dir {
          option.comment = "Direction of the APB access";
        }

        response : coverpoint item.m_response {
          option.comment = "Response of the APB access";
        }

        length : coverpoint item.m_length {
          option.comment = "Length of the APB access";
          bins length_eq_2     = {2};
          bins length_le_10[8] = {[3:10]};
          bins length_gt_10    = {[11:$]};

          illegal_bins length_lt_2 = {[$:1]};
        }

        prev_item_delay : coverpoint item.m_prev_item_delay {
          option.comment = "Delay, in clock cycles, between two consecutive APB accesses";
          bins back2back       = {0};
          bins delay_le_5[5]   = {[1:5]};
          bins delay_gt_5      = {[6:$]};
        }

        response_x_direction : cross response, direction;

        trans_direction : coverpoint item.m_dir {
          option.comment = "Transitions of APB direction";
          bins direction_trans[] = 
          (APB_READ, APB_WRITE => APB_READ, APB_WRITE);
        }
    endgroup: cover_item

    covergroup cover_reg;
      option.per_instance = 1;

      CTRL_OFFSET : coverpoint reg_block.CTRL.OFFSET.value {
        option.comment = "Value of CTRL.OFFSET";
        bins values[]  = {[0:3]};
      }

      CTRL_SIZE : coverpoint reg_block.CTRL.SIZE.value {
        option.comment = "Value of CTRL.SIZE";
        bins values[]  = {[1:4]};
      }

      CTRL_OFFSET_x_CTRL_SIZE : cross CTRL_OFFSET, CTRL_SIZE {
        ignore_bins ignore_ctrl = (binsof(CTRL_OFFSET) intersect {0} && binsof(CTRL_SIZE) intersect {3})       || 
                                  (binsof(CTRL_OFFSET) intersect {1} && binsof(CTRL_SIZE) intersect {2, 3, 4}) || 
                                  (binsof(CTRL_OFFSET) intersect {2} && binsof(CTRL_SIZE) intersect {3, 4})    || 
                                  (binsof(CTRL_OFFSET) intersect {3} && binsof(CTRL_SIZE) intersect {2, 3, 4});
      }
      /*
      IRQ_RX_FIFO_EMPTY : coverpoint reg_block.IRQ.RX_FIFO_EMPTY.value[0] {
        option.comment = "Value of IRQ.RX_FIFO_EMPTY";
      }

      IRQ_RX_FIFO_FULL : coverpoint reg_block.IRQ.RX_FIFO_FULL.value[0] {
        option.comment = "Value of IRQ.RX_FIFO_FULL";
      }

      IRQ_TX_FIFO_EMPTY : coverpoint reg_block.IRQ.TX_FIFO_EMPTY.value[0] {
        option.comment = "Value of IRQ.TX_FIFO_EMPTY";
      }

      IRQ_TX_FIFO_FULL : coverpoint reg_block.IRQ.TX_FIFO_FULL.value[0] {
        option.comment = "Value of IRQ.TX_FIFO_FULL";
      }
      */

      //Note that the data type of value is uvm_reg_data_t, so its size is not the size of the register field, 
      //that's why we used 
      //    bins values[]  = { . . . };
      //    value[0]

    endgroup: cover_reg

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cover_item = new();
      cover_reg = new();  
    endfunction: new  

    function void write(apb_seq_item_mon t);
      item = t;
      cover_item.sample();
      cover_reg.sample();
    endfunction: write

    function string coverage2string();
      coverage2string  = {
        $sformatf("\n  cover_item:                    %.2f%%", cover_item.get_inst_coverage()),
        $sformatf("\n       direction:                %.2f%%", cover_item.direction.get_inst_coverage()),
        $sformatf("\n       trans_direction:          %.2f%%", cover_item.trans_direction.get_inst_coverage()),
        $sformatf("\n       response:                 %.2f%%", cover_item.response.get_inst_coverage()),
        $sformatf("\n       response_x_direction:     %.2f%%", cover_item.response_x_direction.get_inst_coverage()),
        $sformatf("\n       length:                   %.2f%%", cover_item.length.get_inst_coverage()),
        $sformatf("\n       prev_item_delay:          %.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
        $sformatf("\n  cover_reg:                 	  %.2f%%", cover_reg.get_inst_coverage()),
        $sformatf("\n       CTRL_OFFSET:              %.2f%%", cover_reg.CTRL_OFFSET.get_inst_coverage()),
        $sformatf("\n       CTRL_SIZE:                %.2f%%", cover_reg.CTRL_SIZE.get_inst_coverage()),
        $sformatf("\n       CTRL_OFFSET_x_CTRL_SIZE:  %.2f%%", cover_reg.CTRL_OFFSET_x_CTRL_SIZE.get_inst_coverage()),
      /*$sformatf("\n       IRQ_RX_FIFO_EMPTY:        %.2f%%", cover_reg.IRQ_RX_FIFO_EMPTY.get_inst_coverage()),
        $sformatf("\n       IRQ_RX_FIFO_FULL:         %.2f%%", cover_reg.IRQ_RX_FIFO_FULL.get_inst_coverage()),
        $sformatf("\n       IRQ_TX_FIFO_EMPTY:        %.2f%%", cover_reg.IRQ_TX_FIFO_EMPTY.get_inst_coverage()),
        $sformatf("\n       IRQ_TX_FIFO_FULL:         %.2f%%", cover_reg.IRQ_TX_FIFO_FULL.get_inst_coverage()),	*/
        $sformatf("\n  ======================================"),
        $sformatf("\n  OVERALL Coverage:              %.2f%%", $get_coverage())

        };    
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE", coverage2string(), UVM_NONE)
    endfunction

  endclass: apb_coverage_collector

`endif //APB_COVERAGE_COLLECTOR_SV