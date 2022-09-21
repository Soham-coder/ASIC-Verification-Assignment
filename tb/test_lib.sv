///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

class base_test extends uvm_test;
	
	`uvm_component_utils(base_test)

	//Env instance
	env env_inst;
    //ASIC_config cfg_inst;

	//Constructor
  function new(string name = "base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction : new

	//Build Phase
	virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Create the env
	env_inst = env::type_id::create("env_inst", this);
      //cfg_inst = ASIC_config::type_id::create("cfg_inst", this);
      //uvm_config_db#(ASIC_config)::set(this, "*", "cfg_inst", cfg_inst);
	endfunction : build_phase

	//End of elaboration phase
	virtual function void end_of_elaboration();
	//print the topology
	print();
	endfunction : end_of_elaboration

	//---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------   
 function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction : report_phase

endclass : base_test
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
class bringup_test extends base_test;
	//macro
	`uvm_component_utils(bringup_test)

	//sequence instance
	bringup_seq seq_inst;

	//constructor
	function new(string name = "bringup_test", uvm_component parent= null);
		super.new(name, parent);
	endfunction : new

	//build phase
	virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Create bringup seq
	seq_inst = bringup_seq::type_id::create("seq_inst");
	endfunction : build_phase

	// Run phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq_inst.start(env_inst.agent_a_inst.sequencer_inst);
		phase.drop_objection(this);

		//set a drain time for the environment if desired
		phase.phase_done.set_drain_time(this, 50);
	endtask : run_phase

endclass : bringup_test

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
class burst_normal_test extends base_test;

	// Required macro for sequence automation
	`uvm_component_utils(burst_normal_test)

	//sequence instance
	burst_normal_seq seq_inst;

	//constructor
    function new(string name = "burst_normal_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction : new

	// Build phase
	virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Create burst_normal_seq
	seq_inst = burst_normal_seq :: type_id :: create("burst_normal_seq");
	endfunction : build_phase

	//Run phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq_inst.start(env_inst.agent_a_inst.sequencer_inst);
		phase.drop_objection(this);

		//set a drain time for the environment if desired
		phase.phase_done.set_drain_time(this, 50);
	endtask : run_phase

endclass : burst_normal_test
/////////////////////////////////////////////////////////////////////////////