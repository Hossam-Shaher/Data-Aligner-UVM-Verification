`ifndef ALGN_SEQUENCE_CONFIG_REG_SV
  `define ALGN_SEQUENCE_CONFIG_REG_SV
  
  typedef class algn_reg_block;	

  class algn_sequence_config_reg extends uvm_sequence;
    
    `uvm_object_utils(algn_sequence_config_reg)
    
    algn_reg_block reg_block;
    
    function new(string name = "");
      super.new(name);
    endfunction: new
    
    task body();
      uvm_reg 		config_registers[$];
      uvm_status_e 	status;
      
      //Configuration registers are those with "access rights" == "RW" or "WO"
      config_registers =  '{reg_block.CTRL,		//RW
							reg_block.IRQEN,	//RW
                            reg_block.IRQ		//RQ
                           };
            
      config_registers.shuffle();
      
      foreach(config_registers[i]) begin
        assert (config_registers[i].randomize());
        config_registers[i].update(status);
      end 
    endtask: body
    
  endclass: algn_sequence_config_reg

`endif //ALGN_SEQUENCE_CONFIG_REG_SV