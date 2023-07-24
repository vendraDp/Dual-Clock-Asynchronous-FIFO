module WADDRESS_INC 
(output [4:0] w_add,
input  wclk,wfull,winc,wrst_n);
reg [4:0] wbin;
wire [4:0] wgraynext, wbinnext;
 always @(posedge wclk or negedge wrst_n) 
if (!wrst_n) {wbin} <= 0;
else {wbin} <= {wbinnext};
// Memory write-address pointer (okay to use binary to address memory)
assign w_add = wbin[4:0];
assign wbinnext = wbin + (winc & ~wfull);
endmodule