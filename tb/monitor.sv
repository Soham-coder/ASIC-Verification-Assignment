
class monitor extends uvm_monitor;
	//Collected Data handle
	packet pkt;
	// Count packets collected
	int num_pkt_col;
	uvm_analysis_port#(packet) item_collected_port;
       virtual interface dut_if vif;

	//component macro
	`uvm_component_utils_begin(monitor)
 	`uvm_field_int(num_pkt_col, UVM_ALL_ON)
	`uvm_component_utils_end

	// constructor
	function new(string name, uvm_component parent);
	super.new(name, parent);
	endfunction : new

	function void connect_phase(uvm_phase phase);
	if (!(uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)))
		`uvm_error("NO_VIF", {"virtal interface must be set for: ", get_full_name(), ".vif"})
	endfunction : connect_phase
	
	// UVM run() phase
	task run_phase(uvm_phase phase);
	// Look for packets after reset
	@(negedge vif.reset_n)
	@(posedge vif.reset_n)
	forever begin
	`uvm_info(get_type_name(), "Reset deactivated", UVM_LOW)
	pkt = packet::type_id::create("pkt", this);

	fork
		collect();
		// trigger transaction at start of packet
		@(posedge vif.monstart) void'(begin_tr(pkt, "Monitor Packet"));
	join
	// End transaction recording
	end_tr(pkt);
	`uvm_info(get_type_name(), $sformatf("Packet Collected : \n%s", pkt.sprint()), UVM_LOW)
	item_collected_port.write(pkt);
	num_pkt_col++;
	end
	endtask : run_phase

	task collect();
         bit [23:0] byte_1_3;
         bit[15:0] byte_6_7;
      bit[95:0] byte_9_20;
      bit[15:0] byte_3_4;
		logic [7:0] byte_0_temp;
      @(posedge vif.clk iff(vif.in_valid && !vif.in_error))
      while(vif.in_startofpayload === 1)begin
			byte_0_temp = vif.in_data[7:0];
		end
		if(byte_0_temp === 0)begin
          byte_1_3 = {>>{pkt.msg_pssthru_ex_pkt.tx_header.byte_1_3[0], pkt.msg_pssthru_ex_pkt.tx_header.byte_1_3[1],    pkt.msg_pssthru_ex_pkt.tx_header.byte_1_3[2]}};
          byte_6_7 = {>>{pkt.msg_pssthru_ex_pkt.tx_header.byte_6_7[0],          
                          pkt.msg_pssthru_ex_pkt.tx_header.byte_6_7[1]}};
          byte_9_20 = {>>{pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[0],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[1],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[2],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[3],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[4],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[5],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[6],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[7],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[8],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[9],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[10],
           		    pkt.msg_pssthru_ex_pkt.tx_header.byte_9_20[11]}};
			vif.collect_packet_msg_passthru
			( pkt.msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0,
              byte_1_3,
			  pkt.msg_pssthru_ex_pkt.tx_header.byte_4,
			  pkt.msg_pssthru_ex_pkt.tx_header.byte_5,
			  byte_6_7,
			  pkt.msg_pssthru_ex_pkt.tx_header.byte_8,
			  byte_9_20,          
			    pkt.msg_pssthru_ex_pkt.data.message_data,
			    pkt.length_for_msg_pass_thru_return
		    );		
		end
		else if(byte_0_temp === 1)begin
          byte_3_4 = {>>{pkt.reg_wr_ex_pkt.tx_header.byte_3_4[0],
			  pkt.reg_wr_ex_pkt.tx_header.byte_3_4[1]}};
			vif.collect_packet_reg_wr
			( pkt.reg_wr_ex_pkt.tx_header.pkt_tx_type.byte_0,
			  pkt.reg_wr_ex_pkt.tx_header.byte_1,
		  	  byte_3_4,
			  pkt.reg_wr_ex_pkt.data.message_data,
			  pkt.length_for_reg_wr_return
		        );	  
		end
		
	endtask : collect

	//UVM report phase
	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report: Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
	endfunction : report_phase
endclass : monitor