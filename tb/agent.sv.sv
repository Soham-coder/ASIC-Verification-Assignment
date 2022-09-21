/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
class agent extends uvm_agent;
	monitor monitor_inst;
	sequencer sequencer_inst;
	driver driver_inst;
	//ASIC_config cfg_inst;

	// component macro
	`uvm_component_utils_begin(agent)
	`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
	`uvm_component_utils_end
	
    
	//Constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//UVM build phase
	function void build_phase(uvm_phase phase);
      
		super.build_phase(phase);
		monitor_inst = monitor::type_id::create("monitor_inst", this);
		if(is_active == UVM_ACTIVE)begin
			sequencer_inst = sequencer::type_id::create("sequencer_inst", this);
			driver_inst = driver::type_id::create("driver_inst", this);
		end
	endfunction : build_phase
    //Assign the virtual interface of the agents children
	 function void assign_vi(virtual interface dut_if vif);
		 monitor_inst.vif = vif;
		 if(is_active == UVM_ACTIVE)
			 driver_inst.vif = vif;
	 endfunction : assign_vi
	//UVM connect phase
	function void connect_phase(uvm_phase phase);
		if(is_active == UVM_ACTIVE)
			//connect the driver to sequencer
			driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
			//assign_vi(vif); //assign vif
		endfunction : connect_phase

		// Start of simulation
		function void start_of_simulation_phase(uvm_phase phase);
			`uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_LOW)
		endfunction : start_of_simulation_phase

	
endclass: agent
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////