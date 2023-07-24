module rinc_gen(input clock_50,
output reg rinc);

integer count2=1;

always @(posedge clock_50)

begin
 if((count2 > 10 && count2<18) || (count2>20 && count2<50))
 rinc<=1;
 else
 rinc<=0;
 
count2<=count2+1;
 end
endmodule