module winc_gen(input clock_100,
output reg winc);

integer count1=1;

always @(posedge clock_100)

begin
 if(count1<8 || (count1>10 && count1<42) )
 winc<=1;
 else
 winc<=0;
 
count1<=count1+1;
 end
endmodule