`ifndef MD_COVERAGE_COLLECTOR_SV
  `define MD_COVERAGE_COLLECTOR_SV

  typedef class md_seq_item_mon;

  class md_coverage_collector extends uvm_subscriber#(md_seq_item_mon);
    `uvm_component_utils(md_coverage_collector)

    md_seq_item_mon item;

    covergroup cover_item;
        option.per_instance = 1;

        offset : coverpoint item.offset {
          option.comment = "Offset of the MD access";
          bins values[]  = {[0:(`ALGN_DATA_WIDTH /8)-1]};
        }

        size : coverpoint item.size {
          option.comment = "Size of the MD access";
          bins values[]  = {[1:(`ALGN_DATA_WIDTH /8)]};
        }

        response : coverpoint item.response {
          option.comment = "Response of the MD access";
        }

        length : coverpoint item.length {
          option.comment = "Length of the MD access";
          bins length_eq_1     = {1};
          bins length_le_10[9] = {[2:10]};
          bins length_gt_10    = {[11:$]};

          illegal_bins length_lt_1 = {0};
        }

        prev_item_delay : coverpoint item.prev_item_delay {
          option.comment = "Delay, in clock cycles, between two consecutive MD accesses";
          bins back2back       = {0};
          bins delay_le_5[5]   = {[1:5]};
          bins delay_gt_5      = {[6:$]};
        }

        offset_x_size : cross offset, size {
          ignore_bins ignore_offset_plus_size_gt_data_width = offset_x_size with (offset + size > (`ALGN_DATA_WIDTH  / 8));
        }       

    endgroup: cover_item

    function new(string name, uvm_component parent);
        super.new(name, parent);

      cover_item = new();

    endfunction: new  

    function void write(md_seq_item_mon t);
      item = t;

      cover_item.sample();

    endfunction: write

    function string coverage2string();

      coverage2string  = {
        $sformatf("\n  cover_item:                      %.2f%%", cover_item.get_inst_coverage()),
        $sformatf("\n      offset:                      %.2f%%", cover_item.offset.get_inst_coverage()),
        $sformatf("\n      size:                        %.2f%%", cover_item.size.get_inst_coverage()),
        $sformatf("\n      response:                    %.2f%%", cover_item.response.get_inst_coverage()),
        $sformatf("\n      length:                      %.2f%%", cover_item.length.get_inst_coverage()),
        $sformatf("\n      prev_item_delay:             %.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
        $sformatf("\n      offset_x_size:               %.2f%%", cover_item.offset_x_size.get_inst_coverage()),
        $sformatf("\n  ======================================"),
        $sformatf("\n  OVERALL Coverage:                %.2f%%", $get_coverage())

        };    

    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE", coverage2string(), UVM_NONE)
    endfunction

  endclass: md_coverage_collector

`endif //MD_COVERAGE_COLLECTOR_SV