module fifo2 #(parameter DSIZE = 8,parameter datasize =8,
parameter ASIZE = 4)
(output [DSIZE-1:0] rdata,
output wfull,
output rempty,
input [DSIZE-1:0] wdata,
input winc, wclk, wrst_n,
input rinc, rclk, rrst_n,output [datasize-1:0] mem1,output [datasize-1:0] mem2, output [datasize-1:0] mem3,output [datasize-1:0] mem4,output [datasize-1:0] mem5,
output [datasize-1:0] mem6,output [datasize-1:0] mem7,output [datasize-1:0] mem8,output [datasize-1:0] mem9, output [datasize-1:0] mem10,output [datasize-1:0] mem11,
output [datasize-1:0] mem12,
output [datasize-1:0] mem13,output [datasize-1:0] mem14,output [datasize-1:0] mem15,output [datasize-1:0] mem16);

 wire [ASIZE-1:0] waddr, raddr;
 wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;
 
 sync_r2w sync_r2w (.wq2_rptr(wq2_rptr), .rptr(rptr), .wclk(wclk), .wrst_n(wrst_n));
 sync_w2r sync_w2r (.rq2_wptr(rq2_wptr), .wptr(wptr),.rclk(rclk), .rrst_n(rrst_n));
 
 fifo_mem #(DSIZE, ASIZE) fifo_mem(.rdata(rdata), .wdata(wdata),.waddr(waddr), .raddr(raddr),
.wfull(wfull),.wclk(wclk),.mem1(mem1),.mem2(mem2),.mem3(mem3),.mem4(mem4),.mem5(mem5),.mem6(mem6),.mem7(mem7),.mem8(mem8),.mem9(mem9),.mem10(mem10),.mem11(mem11),.mem12(mem12),.mem13(mem13),.mem14(mem14),.mem15(mem15),.mem16(mem16));

 rptr_empty #(ASIZE) rptr_empty(.rempty(rempty),.raddr(raddr),.rptr(rptr), .rq2_wptr(rq2_wptr),
.rclk(rclk),.rrst_n(rrst_n),.rinc(rinc));

 wptr_full #(ASIZE) wptr_full(.wfull(wfull), .waddr(waddr),.wptr(wptr), .wq2_rptr(wq2_rptr),
.wclk(wclk),.wrst_n(wrst_n),.winc(winc));

endmodule
module fifo_mem#( parameter datasize =8,
parameter addrsize =4)
(output [datasize-1:0] rdata,
 input [datasize-1:0] wdata,
 input [addrsize-1:0] waddr, raddr,
input   wfull, wclk,output reg [datasize-1:0] mem1,output reg [datasize-1:0] mem2, output reg  [datasize-1:0] mem3,output reg [datasize-1:0] mem4,output reg [datasize-1:0] mem5,
output reg [datasize-1:0] mem6,output reg [datasize-1:0] mem7,output reg [datasize-1:0] mem8,output reg [datasize-1:0] mem9, output reg [datasize-1:0] mem10,output reg [datasize-1:0] mem11,
output reg [datasize-1:0] mem12,
output reg [datasize-1:0] mem13,output reg [datasize-1:0] mem14,output reg [datasize-1:0] mem15,output reg [datasize-1:0] mem16);
 
 //localparam depth=1<<addrsize;
localparam depth=16;
integer i;
 reg [datasize-1:0] mem[0: depth-1];
 assign rdata = mem[raddr];
always @(posedge wclk) begin
mem1 <= mem[0];mem2 <= mem[1];mem3 <= mem[2];mem4 <= mem[3];mem5 <= mem[4];mem6 <= mem[5];mem7 <= mem[6];mem8 <= mem[7];mem9 <= mem[8];mem10 <= mem[9];mem11 <= mem[10];mem12 <= mem[11];mem13 <= mem[12];mem14 <= mem[13];mem15 <= mem[14];mem16 <= mem[15];


end
 always @(posedge wclk)
 if ( !wfull)
 mem[waddr]<=wdata;
 endmodule
 
 module sync_r2w #(parameter addrsize=4)
(output reg [addrsize:0] wq2_rptr,
input [addrsize:0] rptr,
input wclk, wrst_n);
reg [addrsize:0] wq1_rptr;
always @ (posedge wclk or negedge wrst_n)
if(!wrst_n)
begin
wq1_rptr<=0;
wq2_rptr<=0;
end
else
begin
{wq2_rptr ,wq1_rptr}<={wq1_rptr,rptr};

end
endmodule
module sync_w2r #(parameter addrsize=4)
(output reg [addrsize:0] rq2_wptr,
input [addrsize:0] wptr,
input rclk, rrst_n);
reg [addrsize:0] rq1_wptr;
always @ (posedge rclk or negedge rrst_n)
if(!rrst_n)
begin
rq1_wptr<=0;
rq2_wptr<=0;
end
else
begin
{rq2_wptr , rq1_wptr}<={rq1_wptr, wptr};

end
endmodule


module rptr_empty #(parameter ADDRSIZE = 4)
(output reg rempty,
output [ADDRSIZE-1:0] raddr,
output reg [ADDRSIZE :0] rptr,
input [ADDRSIZE :0] rq2_wptr,
input rinc, rclk, rrst_n);
reg [ADDRSIZE:0] rbin;
wire [ADDRSIZE:0] rgraynext, rbinnext;
//-------------------
// GRAYSTYLE2 pointer
//-------------------
always @(posedge rclk or negedge rrst_n)
if (!rrst_n) {rbin, rptr} <= 0;
else {rbin, rptr} <= {rbinnext, rgraynext};
// Memory read-address pointer (okay to use binary to address memory)
assign raddr = rbin[ADDRSIZE-1:0];
assign rbinnext = rbin + (rinc & ~rempty);
assign rgraynext = (rbinnext>>1) ^ rbinnext;
//---------------------------------------------------------------
// FIFO empty when the next rptr == synchronized wptr or on reset
//---------------------------------------------------------------
assign rempty_val = (rgraynext == rq2_wptr);
always @(posedge rclk or negedge rrst_n)
if (!rrst_n) rempty <= 1'b1;
else rempty <= rempty_val;
endmodule
module wptr_full #(parameter ADDRSIZE = 4)
(output reg wfull,
output [ADDRSIZE-1:0] waddr,
output reg [ADDRSIZE :0] wptr,
input [ADDRSIZE :0] wq2_rptr,
input winc, wclk, wrst_n);
reg [ADDRSIZE:0] wbin;
wire [ADDRSIZE:0] wgraynext, wbinnext;
// GRAYSTYLE2 pointer
always @(posedge wclk or negedge wrst_n)
if (!wrst_n) {wbin, wptr} <= 0;
else {wbin, wptr} <= {wbinnext, wgraynext};
// Memory write-address pointer (okay to use binary to address memory)
assign waddr = wbin[ADDRSIZE-1:0];
assign wbinnext = wbin + (winc & ~wfull);
assign wgraynext = (wbinnext>>1) ^ wbinnext;
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------
assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],
wq2_rptr[ADDRSIZE-2:0]});
always @(posedge wclk or negedge wrst_n)
if (!wrst_n) wfull <= 1'b0;
else wfull <= wfull_val;
endmodule

module tb();
reg [7:0] wdata;
reg wclk, wrst_n, rclk, rrst_n,winc,rinc;
wire rempty,wfull;
wire [7:0] rdata;
integer idx;
wire[7:0] mem_16; wire[7:0] mem_1; wire[7:0] mem_2; wire[7:0] mem_3; wire[7:0] mem_4; wire[7:0] mem_5; wire[7:0] mem_6; wire[7:0] mem_7; wire[7:0] mem_8; wire[7:0] mem_9; wire[7:0] mem_10; wire[7:0] mem_11; wire[7:0] mem_12; wire[7:0] mem_13; wire[7:0] mem_14; wire[7:0] mem_15; 
fifo2 dut(.wdata(wdata),.wclk(wclk),.wrst_n(wrst_n),.rclk(rclk),.rrst_n(rrst_n),.rempty(rempty),.wfull(wfull),.rdata(rdata),.winc(winc),.rinc(rinc),  .mem1(mem_1),  .mem2(mem_2),  .mem3(mem_3),  .mem4(mem_4),  .mem5(mem_5),  .mem6(mem_6),  .mem7(mem_7),  .mem8(mem_8),  .mem9(mem_9),  .mem10(mem_10),  .mem11(mem_11),  .mem12(mem_12),  .mem13(mem_13),  .mem14(mem_14),  .mem15(mem_15),  .mem16(mem_16));

 initial begin
 wclk=0;
 rclk=0;
 
 end
 
 initial begin
 rrst_n=0;#10;rrst_n=1;
 wrst_n=0;#10;wrst_n=1;
 end
 
 always@(wclk)
 begin
 #10 wclk<=~wclk;
 end
 
  always@(rclk)
 begin
 #18 rclk<=~rclk;
 end
 
 initial begin
   wdata=0;
winc=0;
 rinc=0;
 #150;

   wdata=8'h1;
winc=1;
#10 winc=0;
#10

   wdata=8'h2;
winc=1;
#10 winc=0;
#10

   wdata=8'h3;
winc=1;
#10 winc=0;
#10

   wdata=8'h4;
winc=1;
#10 winc=0;
#10

   wdata=8'h5;
winc=1;
#10 winc=0;
#10

   wdata=8'h6;
winc=1;
#10 winc=0;
#10

rinc=1;
#18 rinc=0;
#18

rinc=1;
#18 rinc=0;
#18

rinc=1;
#18 rinc=0;
#18

rinc=1;
#18 rinc=0;
#18

rinc=1;
#18 rinc=0;
#18

rinc=1;
#18 rinc=0;
#18



wdata=8'h7;
winc=1;
#10 winc=0;
#10

wdata=8'h8;
winc=1;
#10 winc=0;
#10

 wdata=8'h9;
winc=1;
#10 winc=0;
#10

   wdata=8'h10;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h12;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h14;
winc=1;
#10 winc=0;
#10

   wdata=8'h15;
winc=1;
#10 winc=0;
#10

 wdata=8'h16;
winc=1;
#10 winc=0;
#10

   wdata=8'h10;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h12;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h14;
winc=1;
#10 winc=0;
#10

   wdata=8'h15;
winc=1;
#10 winc=0;
#10

//read values
#15 rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

//
 wdata=8'h1;
winc=1;
#10 winc=0;
#10

   wdata=8'h2;
winc=1;
#10 winc=0;
#10

   wdata=8'h3;
winc=1;
#10 winc=0;
#10

   wdata=8'h4;
winc=1;
#10 winc=0;
#10

   wdata=8'h5;
winc=1;
#10 winc=0;
#10

   wdata=8'h6;
winc=1;
#10 winc=0;
#10

   wdata=8'h7;
winc=1;
#10 winc=0;
#10

wdata=8'h8;
winc=1;
#10 winc=0;
#10

 wdata=8'h9;
winc=1;
#10 winc=0;
#10

   wdata=8'h10;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h12;
winc=1;
#10 winc=0;
#10

   wdata=8'h11;
winc=1;
#10 winc=0;
#10

   wdata=8'h14;
winc=1;
#10 winc=0;
#10

   wdata=8'h15;
winc=1;
#10 winc=0;
#10

 wdata=8'h16;
winc=1;
#10 winc=0;
#10



//read values
#15 rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15

rinc=1;
#15 rinc=0;
#15


 #100 $finish;
 end
 initial begin
$dumpvars();
end
endmodule
