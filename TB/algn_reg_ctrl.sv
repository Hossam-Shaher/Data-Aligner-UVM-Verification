`ifndef ALGN_REG_CTRL_SV
  `define ALGN_REG_CTRL_SV

  class algn_reg_ctrl extends uvm_reg;
    
    `uvm_object_utils(algn_reg_ctrl)
    
    rand uvm_reg_field SIZE;

    rand uvm_reg_field OFFSET;

    rand uvm_reg_field CLR;
    
    constraint legal_size {
      SIZE.value != 0;
    }
    
    constraint legal_size_offset {
      ((`ALGN_DATA_WIDTH / 8) + OFFSET.value) % SIZE.value == 0;
      OFFSET.value + SIZE.value <= (`ALGN_DATA_WIDTH / 8);
    }
    
    function new(string name = "");
      super.new(.name(name), .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
    endfunction: new
    
    virtual function void build();
      SIZE   = uvm_reg_field::type_id::create(.name("SIZE"),   .parent(null), .contxt(get_full_name()));
      OFFSET = uvm_reg_field::type_id::create(.name("OFFSET"), .parent(null), .contxt(get_full_name()));
      CLR    = uvm_reg_field::type_id::create(.name("CLR"),    .parent(null), .contxt(get_full_name()));
      
      SIZE.configure(
        .parent(                 this),
        .size(                   3),
        .lsb_pos(                0),
        .access(                 "RW"),
        .volatile(               0),
        .reset(                  3'b001),
        .has_reset(              1),
        .is_rand(                1),
        .individually_accessible(0));
      
      OFFSET.configure(
        .parent(                 this),
        .size(                   2),
        .lsb_pos(                8),
        .access(                 "RW"),
        .volatile(               0),
        .reset(                  2'b00),
        .has_reset(              1),
        .is_rand(                1),
        .individually_accessible(0));
      
      CLR.configure(
        .parent(                 this),
        .size(                   1),
        .lsb_pos(                16),
        .access(                 "WO"),
        .volatile(               0),
        .reset(                  1'b0),
        .has_reset(              1),
        .is_rand(                1),
        .individually_accessible(0));
      
    endfunction: build

  endclass: algn_reg_ctrl

`endif //ALGN_REG_CTRL_SV