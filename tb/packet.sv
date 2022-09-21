
class packet extends uvm_sequence_item;

//`uvm_object_utils(packet)


rand packet_transaction_type_e pkt_transition_type_e; //enum
rand message_type_e msg_type_e; //enum
rand mode_e mode_ee; //enum

rand message_passthrough_exchange_packet msg_pssthru_ex_pkt; //structs
rand register_write_exchange_packet reg_wr_ex_pkt; //structs

rand bit[9:0] length_for_msg_pass_thru;
rand bit[9:0] length_for_reg_wr;
bit[9:0] length_for_msg_pass_thru_return;
bit[9:0] length_for_reg_wr_return;
rand bit[22:0] start_address;
rand bit[8:0] burst_size;
rand bit[31:0] addr;
rand bit[31:0] data;
rand bit[31:0] burst_config;


`uvm_object_utils_begin(packet)
  `uvm_field_enum(packet_transaction_type_e, pkt_transition_type_e,  UVM_ALL_ON)
  `uvm_field_enum(message_type_e, msg_type_e, UVM_ALL_ON)
  `uvm_field_enum(mode_e, mode_ee, UVM_ALL_ON)
  `uvm_field_int(length_for_msg_pass_thru, UVM_ALL_ON)
  `uvm_field_int(length_for_reg_wr, UVM_ALL_ON)
  `uvm_field_int(start_address, UVM_ALL_ON)
  `uvm_field_int(burst_size, UVM_ALL_ON)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_field_int(burst_config, UVM_ALL_ON)
	//`uvm_field_int(msg_pssthru_ex_pkt, UVM_NOPRINT)
	//`uvm_field_int(reg_wr_ex_pkt, UVM_NOPRINT)
`uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "packet");
    super.new(name);
  endfunction

constraint burst_config_c { burst_config == {burst_size, start_address}; }



constraint pkt_tx_type_c { 
	pkt_transition_type_e == MESSAGE_PASSTHROUGH -> msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0 == 0 && reg_wr_ex_pkt.tx_header.pkt_tx_type.byte_0 == 0;
	pkt_transition_type_e == REGISTERS_UPDATE -> msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0 == 1 && reg_wr_ex_pkt.tx_header.pkt_tx_type.byte_0 == 1;
	pkt_transition_type_e == RESERVED_TX ->  msg_pssthru_ex_pkt.tx_header.pkt_tx_type.byte_0  inside {[2:255]} && reg_wr_ex_pkt.tx_header.pkt_tx_type.byte_0 inside {[2:255]};
}

constraint msg_passthru_msg_type_c {
        msg_type_e == MASS_QUOTE -> msg_pssthru_ex_pkt.tx_header.byte_4 == 0;
	msg_type_e == HEARTBEAT -> msg_pssthru_ex_pkt.tx_header.byte_4 == 1;
	msg_type_e == RESERVED_MX_TYPE -> msg_pssthru_ex_pkt.tx_header.byte_4 inside {[2:255]};
}

constraint reg_wr_mode_c {
	mode_ee == NORMAL -> reg_wr_ex_pkt.tx_header.byte_2 == 0;
	mode_ee == BURST -> reg_wr_ex_pkt.tx_header.byte_2 == 1;
}

constraint reg_wr_NORMAL_MODE { foreach(reg_wr_ex_pkt.data.message_data[ii])
					if(mode_ee == NORMAL)
					({reg_wr_ex_pkt.data.message_data[ii], reg_wr_ex_pkt.data.message_data[ii+1], reg_wr_ex_pkt.data.message_data[ii+2], reg_wr_ex_pkt.data.message_data[ii+3]} == addr) && ({reg_wr_ex_pkt.data.message_data[ii+4], reg_wr_ex_pkt.data.message_data[ii+5], reg_wr_ex_pkt.data.message_data[ii+6], reg_wr_ex_pkt.data.message_data[ii+7]} == data);
			      }

constraint reg_wr_BURST_MODE {
	foreach(reg_wr_ex_pkt.data.message_data[ii])
					if(mode_ee == BURST)
					({reg_wr_ex_pkt.data.message_data[ii], reg_wr_ex_pkt.data.message_data[ii+1], reg_wr_ex_pkt.data.message_data[ii+2], reg_wr_ex_pkt.data.message_data[ii+3]} == burst_config) && ({reg_wr_ex_pkt.data.message_data[ii+4], reg_wr_ex_pkt.data.message_data[ii+5], reg_wr_ex_pkt.data.message_data[ii+6], reg_wr_ex_pkt.data.message_data[ii+7]} == data) && ({reg_wr_ex_pkt.data.message_data[ii+8], reg_wr_ex_pkt.data.message_data[ii+9], reg_wr_ex_pkt.data.message_data[ii+10], reg_wr_ex_pkt.data.message_data[ii+11]} == data);

} 

constraint length_msg_pass_thru { length_for_msg_pass_thru >= 128; length_for_msg_pass_thru <= 1017; }

constraint msg_passthru_payload_size_c { length_for_msg_pass_thru == msg_pssthru_ex_pkt.data.message_data.size(); } 

constraint length_reg_wr_c { length_for_reg_wr >= 1; length_for_reg_wr <= 1016; }

constraint reg_wr_payload_size_c { length_for_reg_wr == reg_wr_ex_pkt.data.message_data.size(); }

function bit[9:0] calc_length_msg_pass_thru();
     calc_length_msg_pass_thru = length_for_msg_pass_thru;
endfunction : calc_length_msg_pass_thru

function bit[9:0] calc_length_reg_wr();
	calc_length_reg_wr = length_for_reg_wr;
endfunction : calc_length_reg_wr

function void set_length_msg_pass_thru();
	length_for_msg_pass_thru_return = calc_length_msg_pass_thru();
endfunction : set_length_msg_pass_thru

function void set_length_reg_wr();
	length_for_reg_wr_return = calc_length_reg_wr();
endfunction : set_length_reg_wr

//Post_randomize()
function void post_randomize();
	set_length_msg_pass_thru();
	set_length_reg_wr();
endfunction : post_randomize

endclass
