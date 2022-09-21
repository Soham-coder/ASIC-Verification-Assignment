module dut
  
  
  
  (
    input clk,
    input reset_n,
    input in_valid,
    input in_startofpayload,
    input in_endofpayload,
    output in_ready,
    input [63:0] in_data,
    input[2:0] in_empty,
    input in_error);
  reg in_ready;
  
  always@(posedge clk)
    if(reset_n)begin
  in_ready <= 1;
  end
  
endmodule: dut