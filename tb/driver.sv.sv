///////////////////////////////////////////////////////////////


class driver extends uvm_driver #(packet);

	virtual interface dut_if vif;
        //to count the no of packets sent
	int num_sent;
	// component macro
	`uvm_component_utils_begin(driver)
	`uvm_field_int(num_sent, UVM_ALL_ON)
	`uvm_component_utils_end
	
	//Constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void connect_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
			`uvm_error("NO_VIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
	endfunction: connect_phase

	//start_of_simulation
	function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
	endfunction : start_of_simulation_phase

	//Driver Run phase
	task run_phase(uvm_phase phase);
		fork
			get_and_drive();
			reset_signals();
		join
	endtask : run_phase

	task get_and_drive();
		@(negedge vif.reset_n); //reset is activated
		@(posedge vif.reset_n); //reset is deactivated
		`uvm_info(get_type_name(), "Reset Dropped", UVM_LOW)
		forever begin
			//Get new item from sequencer
			seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_LOW)
			fork
				begin
					drive();
				end
			@(posedge vif.drvstart)
			void'(begin_tr(req, "Driver driving packet"));		

			join

			// End transacion recording
		end_tr(req);
		num_sent++;
		seq_item_port.item_done();
        end
        endtask: get_and_drive

	task drive();
	@(posedge vif.clk);
	if(req.msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0 === 0)
	begin
		vif.send_to_dut_msg_passthru
		(
			req.msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0,
                        {req.msg_pssthru_ex_pkt.tx_header.byte_1_3[0],req.msg_pssthru_ex_pkt.tx_header.byte_1_3[1],req.msg_pssthru_ex_pkt.tx_header.byte_1_3[2]},
			req.msg_pssthru_ex_pkt.tx_header.byte_4,
			req.msg_pssthru_ex_pkt.tx_header.byte_5,
                        {req.msg_pssthru_ex_pkt.tx_header.byte_6_7[0],          
                        req.msg_pssthru_ex_pkt.tx_header.byte_6_7[1]}, 
			req.msg_pssthru_ex_pkt.tx_header.byte_8,
                        {req.msg_pssthru_ex_pkt.tx_header.byte_9_20[0],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[1],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[2],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[3],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[4],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[5],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[6],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[7],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[8],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[9],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[10],
           		req.msg_pssthru_ex_pkt.tx_header.byte_9_20[11]},
			req.msg_pssthru_ex_pkt.data.message_data,
			req.length_for_msg_pass_thru

        );
    end
    else if (req.msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0 === 1)
    begin
	vif.send_to_dut_register_write_data
        (
		req.reg_wr_ex_pkt.tx_header.pkt_tx_type.byte_0,
		req.reg_wr_ex_pkt.tx_header.byte_1,
		{req.reg_wr_ex_pkt.tx_header.byte_3_4[0],
	        req.reg_wr_ex_pkt.tx_header.byte_3_4[1]},
		req.reg_wr_ex_pkt.data.message_data,
		req.length_for_reg_wr	
		
	);	
    end
    endtask: drive

	//Reset all TX signals
	task reset_signals();
	forever
		vif.dut_if_reset();
	endtask

	// UVM report phase
	function void report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report : Driver sent %0d packets", num_sent), UVM_LOW)
	endfunction : report_phase	


endclass : driver
