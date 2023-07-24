module mem_store(input rinc, rempty, rrst_n, rclk, 
output [4:0]r_addr);
reg [4:0] rbin;
wire [4:0] rbinnext;
always @ (posedge rclk or negedge rrst_n)
if(!rrst_n)
rbin<=0;
else
rbin<=rbinnext;
assign  r_addr=rbin;
assign rbinnext = rbin + (rinc & ~rempty);
endmodule



