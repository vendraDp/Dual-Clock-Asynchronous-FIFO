module rrst_gen(input clk,
output reg rrst_n);

integer count3=1;

always @(posedge clk)

begin
 if(count3<11)
 rrst_n<=1;
 else
rrst_n<=0;
 
count3<=count3+1;
 end
endmodule