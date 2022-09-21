
class base_seq extends uvm_sequence#(packet);

	//Required macro for sequence automation
	`uvm_object_utils(base_seq)

	//Constructor
	function new(string name = "base_seq");
		super.new(name);
	endfunction

	task pre_body();
		uvm_phase phase;
		`ifdef UVM_VERSION_1_2
			phase = get_starting_phase();
		`else
			phase = starting_phase;
		`endif
		if(phase != null)begin
			phase.raise_objection(this, get_type_name());
			`uvm_info(get_type_name(), "raise objection", UVM_LOW)
		end
	endtask : pre_body

	task post_body();
		uvm_phase phase;
		`ifdef UVM_VERSION_1_2
			phase = get_starting_phase();
		`else
			phase = starting_phase;
		`endif
		if(phase != null)begin
			phase.drop_objection(this, get_type_name());
			`uvm_info(get_type_name(), "drop objection", UVM_LOW)
		end
	endtask: post_body
endclass : base_seq

/////// Seq which does bringup ////////////////////
class bringup_seq extends base_seq;
	
	//Required macro for sequence automation
	`uvm_object_utils(bringup_seq)

	//Constructor
	function new(string name = "bringup_seq");
		super.new(name);
	endfunction : new

	//Sequence body definition
	virtual task body();
      `uvm_info(get_type_name(), "Executing bringup_seq", UVM_LOW)
		#10us;
	endtask
endclass : bringup_seq


/////// Seq sends burst packet and then normal packet
class burst_normal_seq extends base_seq;

	// Required macro for sequence automation
	`uvm_object_utils(burst_normal_seq)

	//Constructor
	function new(string name = "burst_normal_seq");
		super.new(name);
	endfunction : new

	// Sequence body definition
	virtual task body();
		`uvm_info(get_type_name(), "Executing burst_normal_seq", UVM_LOW)
		`uvm_do_with(req, {req.pkt_transition_type_e == REGISTERS_UPDATE && req.mode_ee == BURST;})
		`uvm_do_with(req, {req.pkt_transition_type_e == REGISTERS_UPDATE && req.mode_ee == NORMAL;})

	endtask
endclass : burst_normal_seq