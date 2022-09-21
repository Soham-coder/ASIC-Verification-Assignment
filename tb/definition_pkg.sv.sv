package definitions;
	
	typedef struct  {
		logic [7:0] byte_0;
	} packet_transaction_type;

	typedef struct  { 
		packet_transaction_type pkt_tx_type;
	        logic [7:0] byte_1_3[3];
	        logic [7:0] byte_4;
		logic [7:0] byte_5;
		logic [7:0] byte_6_7[2];
		logic [7:0] byte_8;
		logic [7:0] byte_9_20[12];
	} message_passthrough_data_format_tx_header; 

	typedef struct  {
		packet_transaction_type pkt_tx_type;
	        logic [7:0] byte_1;
		logic [7:0] byte_2;
		logic [7:0] byte_3_4[2];
	} register_write_data_format_tx_header;

	typedef struct  {
		logic [7:0] message_data[];
	} message_passthrough_data_format_pkt_data_s;

	typedef struct {
                logic [7:0] message_data[];
	} register_write_data_format_pkt_data_s;

	/*typedef union  {
      logic [31:0]dword_message_data[];
	        message_passthrough_data_format_pkt_data_s message_passthrough_data;
	} message_passthrough_data_format_pkt_data_u ; //For accessing via DWORDs*/
	
	/*typedef union  {
		logic [31:0] dword_message_data[];
		register_write_data_format_pkt_data_s register_write_data;
    } register_write_data_format_pkt_data_u ; //For accessing via DWORDS*/

	typedef struct {
		message_passthrough_data_format_tx_header tx_header;
	        message_passthrough_data_format_pkt_data_s data;
        } message_passthrough_exchange_packet; //Whole packet

	typedef struct {
		 register_write_data_format_tx_header tx_header;
	         register_write_data_format_pkt_data_s data;
	 } register_write_exchange_packet; //Whole packet



typedef enum { MESSAGE_PASSTHROUGH, REGISTERS_UPDATE, RESERVED_TX } packet_transaction_type_e;
typedef enum { MASS_QUOTE, HEARTBEAT, RESERVED_MX_TYPE } message_type_e;
typedef enum { NORMAL, BURST } mode_e;


endpackage
