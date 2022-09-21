class env extends uvm_env;

	agent agent_a_inst; //Active agent
	agent agent_p_inst; //Passive agent

	`uvm_component_utils(env)

	//constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//UVM build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agent_a_inst = agent::type_id::create("agent_a_inst", this);
		agent_p_inst = agent::type_id::create("agent_p_inst", this);
		uvm_config_db#(uvm_active_passive_enum)::set(this, "agent_p_inst", "is_active", UVM_PASSIVE);
      //if(!uvm_config_db #(ASIC_config) :: get(this, "", "cfg_inst", cfg_inst)
        // uvm_config_db#(ASIC_config)::set(this, "*", "cfg_inst", config_inst);
	endfunction : build_phase

	//Start of simulation
	function void start_of_simulation_phase(uvm_phase phase);
		 `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_LOW)
	endfunction : start_of_simulation_phase
endclass : env