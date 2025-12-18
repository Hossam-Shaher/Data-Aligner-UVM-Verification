`ifndef ALGN_SEQUENCE_STATUS_REG_SV
  `define ALGN_SEQUENCE_STATUS_REG_SV
  
  typedef class algn_reg_block;	

  class algn_sequence_status_reg extends uvm_sequence;
    
    `uvm_object_utils(algn_sequence_status_reg)
    
    algn_reg_block reg_block;
    
    function new(string name = "");
      super.new(name);
    endfunction: new
    
    task body();
      uvm_reg 			status_registers[$];
      uvm_status_e 		status;
      uvm_reg_data_t 	data;
      
      //status registers are those with "access rights" == "RO"
      status_registers =  '{ reg_block.STATUS };
      
      status_registers.shuffle();
      
      foreach(status_registers[i]) begin
        status_registers[i].read(status, data);
      end 
    endtask: body
    
  endclass: algn_sequence_status_reg

`endif //ALGN_SEQUENCE_STATUS_REG_SV