 module WRITE_RST_N 
 (output reg  wrst_n,
input clk);
integer count=0;
always @( posedge clk)
begin
if (count<2) 
wrst_n <= 1;
else 
wrst_n <= 0;

count <=  count +1 ;
 end
endmodule