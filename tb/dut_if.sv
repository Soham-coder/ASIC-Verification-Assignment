
///////////////////////////////////////////////////////////////


interface dut_if ( input clk, input reset_n );
	timeunit 1ns;
	timeprecision 100ps;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	//Actual signals
	logic	in_valid;
	logic	in_startofpayload;
	logic	in_endofpayload;
	logic	in_ready;
	logic [63:0] in_data;
	logic [2:0] in_empty;
	logic in_error;

	// signal for transaction recording
	bit monstart, drvstart;


  logic[7:0] message_data_payload_msg_passthru[0:1017];
  logic[7:0] message_data_payload_reg_wr[0:1016];

	task dut_if_reset();
		@(negedge reset_n);
		in_valid	<= 1'b0;
		in_startofpayload <= 1'b0;
		in_endofpayload <= 1'b0;
		in_data <= 'hz;
		in_empty <= 3'b0;
		in_error <= 1'b0;
		disable send_to_dut_msg_passthru;
	endtask : dut_if_reset

	//Gets a message passthrough data and drive it into DUT
	task send_to_dut_msg_passthru(input bit[7:0] byte_0,
					    bit[7:0] byte_1_3[3],
					    bit[7:0] byte_4,
					    bit[7:0] byte_5,
					    bit[7:0] byte_6_7[2],
					    bit[7:0] byte_8,
		                            bit[7:0] byte_9_20[12],
                                            bit[7:0] message_data[],
                                            bit[9:0] length_for_msg_pass_thru
				     );
      
                static int cnt;
        logic [7:0] message_data_last_msg_pass_thru[];
		// Start to send packet if in_ready is asserted
		@(posedge clk iff(in_ready));
		// trigger for transaction recording
		drvstart = 1'b1;
		// enable startofpayload signal
		in_startofpayload <= 1'b1; //High for one clock cycle
		in_valid <= 1'b1;
                in_data <= {byte_0, byte_1_3[0],byte_1_3[1],byte_1_3[2], byte_4, byte_5, byte_6_7[0], byte_6_7[1]}; //1st 64 chunk of data
		@(posedge clk iff(in_ready))
		in_valid <= 1'b1;
		in_startofpayload <= 1'b0; //Goes low in the next clock cycle
                in_data <= {byte_8, byte_9_20[0],byte_9_20[1], byte_9_20[2],byte_9_20[3],byte_9_20[4], byte_9_20[5], byte_9_20[6]}; //2nd 64 chunk of data
		@(posedge clk iff(in_ready))
		in_valid <= 1'b1;
      if ((!($isunknown(message_data_payload_msg_passthru[0])) || !($isunknown(message_data_payload_msg_passthru[1])) || !($isunknown(message_data_payload_msg_passthru[2])))) 
                in_data <= {byte_9_20[7], byte_9_20[8], byte_9_20[9], byte_9_20[10], byte_9_20[11], message_data_payload_msg_passthru[0], message_data_payload_msg_passthru[1], message_data_payload_msg_passthru[2]} ;
		//Drive payload
      for(int i=3; i<$floor((length_for_msg_pass_thru-3)/8); i++)begin
			@(posedge clk iff(in_ready))
			if(!$isunknown({message_data_payload_msg_passthru[i], message_data_payload_msg_passthru[i+1], message_data_payload_msg_passthru[i+2], message_data_payload_msg_passthru[i+3], message_data_payload_msg_passthru[i+4], message_data_payload_msg_passthru[i+5], message_data_payload_msg_passthru[i+6], message_data_payload_msg_passthru[i+7]}))
			in_valid <= 1'b1;
                        in_data <= {message_data_payload_msg_passthru[i],message_data_payload_msg_passthru[i+1], message_data_payload_msg_passthru[i+2], message_data_payload_msg_passthru[i+3], message_data_payload_msg_passthru[i+4], message_data_payload_msg_passthru[i+5], message_data_payload_msg_passthru[i+6], message_data_payload_msg_passthru[i+7]};
                        //$display("message_data_payload_msg_passthru[%0d], message_data_payload_msg_passthru[%0d], message_data_payload_msg_passthru[%0d], message_data_payload_msg_passthru[%0d]", i, i+1, i+2, i+3);
		end
		@(posedge clk iff(in_ready))
		in_valid <= 1'b1;
      for(int i = $floor((length_for_msg_pass_thru - 3)/8)*8; i < length_for_msg_pass_thru; i++)begin
        if(!$isunknown(message_data_payload_msg_passthru[i]))
		       message_data_last_msg_pass_thru[cnt] = message_data_payload_msg_passthru[i];
	       	       cnt++;
		end
		in_data  = {>>{message_data_last_msg_pass_thru}};	
		in_endofpayload <= 1'b1;
		in_empty <= 8 - cnt; //Since these many bytes are empty at the last

		@(posedge clk iff(in_ready))
		in_endofpayload <= 1'b0;
		in_error <= 1'b0; //no error as such
		in_valid <= 1'b0;
		@(posedge clk)
		in_data <= 'hz;
		drvstart = 1'b0;
	endtask: send_to_dut_msg_passthru
        
	//Gets a register write data and drive it into DUT
	task send_to_dut_register_write_data(input bit[7:0] byte_0,
		  				   bit[7:0] byte_1,
						   bit[7:0] byte_3_4[2],
						   bit[7:0] message_data[],
						   bit[9:0] length_for_reg_wr
					    );
		static int cnt;
        logic [7:0] message_data_last_reg_wr[];
		// Start to send packet if in_ready is asserted
	        @(posedge clk iff(in_ready));
		// trigger for transaction recording
		drvstart = 1'b1;
		//enable startofpayload signal
		in_startofpayload <= 1'b1;
		in_valid <= 1'b1;
      if((!($isunknown(message_data_payload_reg_wr[0])) || !($isunknown(message_data_payload_reg_wr[1])) || !($isunknown(message_data_payload_reg_wr[2])) || ($isunknown(message_data_payload_reg_wr[3])) ))
		in_data <= { byte_0, byte_1, byte_3_4[0], byte_3_4[1], message_data_payload_reg_wr[0], message_data_payload_reg_wr[1], message_data_payload_reg_wr[2], message_data_payload_reg_wr[3] }; // 4 bytes of empty data
		//Drive payload
      for(int i=4; i<$floor((length_for_reg_wr-4)/8); i++)begin
		@(posedge clk iff(in_ready));
		if(!$isunknown({message_data_payload_reg_wr[i], message_data_payload_reg_wr[i+1], message_data_payload_reg_wr[i+2], message_data_payload_reg_wr[i+3], message_data_payload_reg_wr[i+4], message_data_payload_reg_wr[i+5], message_data_payload_reg_wr[i+6], message_data_payload_reg_wr[i+7]}))
		in_valid <= 1'b1;
		in_startofpayload <= 1'b0; //Goes low in the next clock cycle
		in_data <= { message_data_payload_reg_wr[i], message_data_payload_reg_wr[i+1], message_data_payload_reg_wr[i+2], message_data_payload_reg_wr[i+3], message_data_payload_reg_wr[i+4], message_data_payload_reg_wr[i+5], message_data_payload_reg_wr[i+6], message_data_payload_reg_wr[i+7]};   
	        end
		@(posedge clk iff(in_ready))
		in_valid <= 1'b1;
      for(int j = $floor((length_for_reg_wr-4)/8)*8; j < length_for_reg_wr; j++)begin
        if(!$isunknown(message_data_payload_reg_wr[j]))
				message_data_last_reg_wr[cnt] = message_data_payload_reg_wr[j];
				cnt++;
		end
        in_data = {>>{message_data_last_reg_wr}};
		in_endofpayload <= 1'b1;
		in_empty <= 8 - cnt; //since these many bytes are empty at the last

		@(posedge clk iff(in_ready))
		in_endofpayload <= 1'b0;
		in_error <= 1'b0; //no error as such
		in_valid <= 1'b0;
		@(posedge clk)
		in_data <= 'hz;
		drvstart = 1'b0;
	endtask: send_to_dut_register_write_data
  
  
  task collect_packet_msg_passthru(output bit[7:0] byte_0,
                                   bit[23:0] byte_1_3,
					   	bit[7:0] byte_4,
					    	bit[7:0] byte_5,
                                   bit[15:0] byte_6_7,
					    	bit[7:0] byte_8,
                                   bit[95:0] byte_9_20,
                                            	bit[7:0] message_data[],
                                            	bit[9:0] length_for_msg_pass_thru);

				@(posedge clk iff(in_valid && !in_error))
				monstart = 1'b1;
				`uvm_info("DUT_IF", "collect packets for message passthrough", UVM_LOW)
				while(in_startofpayload === 1)begin
					{byte_0, byte_1_3[0],byte_1_3[1],byte_1_3[2], byte_4, byte_5, byte_6_7[0], byte_6_7[1]}  =  in_data;
				end
				@(posedge clk iff (in_valid && !in_error))
    {byte_8, byte_9_20[0],byte_9_20[1], byte_9_20[2],byte_9_20[3],byte_9_20[4], byte_9_20[5], byte_9_20[6]} = in_data;
				@(posedge clk iff (in_valid && !in_error))
				message_data = new[length_for_msg_pass_thru]; //allocate the payload
				{byte_9_20[7], byte_9_20[8], byte_9_20[9], byte_9_20[10], byte_9_20[11], message_data[0], message_data[1], message_data[2]} = in_data;
				for(int j=3; j<$floor((length_for_msg_pass_thru-3/8)); j++)begin
				@(posedge clk iff (in_valid && !in_error))
				{message_data[j], message_data[j+1], message_data[j+2], message_data[j+3], message_data[j+4], message_data[j+5], message_data[j+6], message_data[j+7]} = in_data; 
				end
				@(posedge clk iff(in_valid && !in_error))
				while(in_endofpayload === 1)begin
					{message_data[length_for_msg_pass_thru-7], message_data[length_for_msg_pass_thru-6], message_data[length_for_msg_pass_thru-5], message_data[length_for_msg_pass_thru-4], message_data[length_for_msg_pass_thru-3], message_data[length_for_msg_pass_thru-2], message_data[length_for_msg_pass_thru-1], message_data[length_for_msg_pass_thru]} = in_data;
				end
				endtask: collect_packet_msg_passthru
  task collect_packet_reg_wr(input bit[7:0] byte_0,
					  bit[7:0] byte_1,
                      bit[15:0] byte_3_4,
					  bit[7:0] message_data[],
					  bit[9:0] length_for_reg_wr);
				  @(posedge clk iff(in_valid && !in_error))
				  monstart = 1'b1;
				  `uvm_info("DUT_IF", "collect packets for reg wr", UVM_LOW)
				  while(in_startofpayload === 1)begin
					   message_data = new[length_for_reg_wr]; //allocate the payload
					  {byte_0, byte_1, byte_3_4[0], byte_3_4[1], message_data[0], message_data[1], message_data[2], message_data[3]} = in_data;
				  end
				  @(posedge clk iff(in_valid && !in_error))
				  for(int j = 4; j<$floor((length_for_reg_wr-4)/8); j++)begin
					  @(posedge clk iff(in_valid && !in_error))
					  {message_data[j], message_data[j+1], message_data[j+2], message_data[j+3], message_data[j+4], message_data[j+5], message_data[j+6], message_data[j+7]} = in_data;
				  end
				  @(posedge clk iff(in_valid && !in_error))
				  while(in_endofpayload === 1)begin
					  {message_data[length_for_reg_wr-7], message_data[length_for_reg_wr-6], message_data[length_for_reg_wr-5], message_data[length_for_reg_wr-4], message_data[length_for_reg_wr-3], message_data[length_for_reg_wr-2], message_data[length_for_reg_wr-1], message_data[length_for_reg_wr]} = in_data;
					  monstart = 1'b0;
				  end 


			  endtask: collect_packet_reg_wr
  
endinterface : dut_if