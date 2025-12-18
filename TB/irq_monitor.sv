`ifndef IRQ_MONITOR_SV
  `define IRQ_MONITOR_SV

  class irq_monitor extends uvm_monitor;
    `uvm_component_utils(irq_monitor)

    virtual algn_if algn_vif;
    uvm_analysis_port#(bit)	ap;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      ap = new("ap", this);

      if( ! uvm_config_db#(virtual algn_if)::get(this, "", "algn_vif", algn_vif) ) begin
          `uvm_error( this.get_full_name, "algn_vif NOT found" )
      end   
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      forever begin
          monitor();  
      end
    endtask: run_phase

    protected task monitor();

      @( posedge algn_vif.clk iff(algn_vif.irq && algn_vif.reset_n) );

      ap.write(1);

      `uvm_info(this.get_name, $sformatf("irq = %0d", algn_vif.irq), UVM_LOW) 
    endtask: monitor

  endclass: irq_monitor

`endif //IRQ_MONITOR_SV