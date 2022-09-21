// Code your testbench here
// or browse Examples
//`include "design.sv"
// import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"


`include "ASIC_pkg.svh"
`include "dut_if.sv"
module tb;
  
  /*bit[7:0] byte_0;
  bit[7:0] byte_1_3[3];
  bit[7:0] byte_4;
  bit[7:0] byte_5;
  bit[7:0] byte_6_7[2];
  bit[7:0] byte_8;
  bit[7:0] byte_9_20[12];
  bit[7:0] message_data[];
  bit[9:0] length_for_msg_pass_thru;*/
      
      
      //-----------------------------------------------------------------------------
// Clock Generation Module; Flips every 10ns => Freq = 50 MHz 
//-----------------------------------------------------------------------------
   bit reset_n;
   bit clk;
   always #10 clk <= ~clk; 

//-----------------------------------------------------------------------------
// Instantiate the Interface and pass it to Design Wrapper
//-----------------------------------------------------------------------------
      dut_if         dut_if_inst  (clk, reset_n);
  
      //---------------------------------------
  //DUT instance
  //---------------------------------------
    dut DUT_INST (
      .clk(dut_if_inst.clk),
      .reset_n(dut_if_inst.reset_n),
      .in_valid(dut_if_inst.in_valid),
      .in_startofpayload(dut_if_inst.in_startofpayload),
      .in_endofpayload(dut_if_inst.in_endofpayload),
      .in_ready(dut_if_inst.in_ready),
      .in_data(dut_if_inst.in_data),
      .in_empty(dut_if_inst.in_empty),
      .in_error(dut_if_inst.in_error)
   );

//-----------------------------------------------------------------------------
// At start of simulation, set the interface handle as a config object in UVM 
// database. This IF handle can be retrieved in the test using the get() method
// run_test () accepts the test name as argument. In this case, base_test will
// be run for simulation
//-----------------------------------------------------------------------------
   initial begin
     uvm_config_db #(virtual dut_if)::set (null, "*", "vif", dut_if_inst);
     run_test ();
   end
  initial begin
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  initial begin
    reset_n = 0;
    #50;
    reset_n = 1;
  end

      //dut_if_inst.send_to_dut_msg_passthru(byte_0, byte_1_3[0:2], byte_4, byte_5, byte_6_7[0:1], byte_8, byte_9_20[0:11], message_data, length_for_msg_pass_thru);
endmodule 
