class sequencer extends uvm_sequencer #(packet);
	
	packet packet_inst;
	
	`uvm_component_utils(sequencer)
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction
	
	//start of simulation
	function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_LOW)
	endfunction : start_of_simulation_phase
endclass : sequencer