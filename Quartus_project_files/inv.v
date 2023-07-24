module inv(input inp,
output reg out_inv);



always @(*)

begin
out_inv<=~inp;
 end
endmodule