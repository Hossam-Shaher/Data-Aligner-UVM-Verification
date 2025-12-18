`ifndef ALGN_SEQUENCE_REG_ACCESS_SV
  `define ALGN_SEQUENCE_REG_ACCESS_SV
  
  typedef class algn_reg_block;
    
  class algn_sequence_reg_access extends uvm_sequence;

    `uvm_object_utils(algn_sequence_reg_access)

    algn_reg_block reg_block;
    
    rand int unsigned num_accesses;
    rand int unsigned delay;
    
    constraint num_accesses_default_constraint {
      soft num_accesses inside {[100:110]};
  	}
    constraint delay_default_constraint {
      soft delay inside {[0:20]};
  	}

    function new(string name = "");
      super.new(name);
    endfunction: new
    
    task body();
      uvm_reg 			registers[$]; 
      uvm_status_e 		status;
      uvm_reg_data_t 	data;
      
      reg_block.get_registers(registers);
      
      repeat (num_accesses) begin
        registers.shuffle();
        
        //write_access
        assert (registers[0].randomize());
        registers[0].update(status);
        
        //read_access
        registers[0].read(status, data);
        
        //Note 1:
        //Some register fields are WO
        
        //Note 2:
        //Do not forget to call: default_map.set_check_on_read(1);
        
        //Note 3:
        //It may be useful to display predictor info reports (UVM_HIGH).
        //predictor.set_report_verbosity_level(UVM_HIGH);
              
        #(delay);
      end
      
    endtask: body
    
  endclass: algn_sequence_reg_access

`endif	//ALGN_SEQUENCE_REG_ACCESS_SV