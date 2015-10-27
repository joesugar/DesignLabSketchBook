`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:27:49 10/25/2015 
// Design Name: 
// Module Name:    async_flagack 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   Flag going from clock domain A to clock domain B with ack.
//   Code obtained from http://www.fpga4fun.com/CrossClockDomain2.html
//
//////////////////////////////////////////////////////////////////////////////////
module async_flagack(
    input clkA,
    input FlagIn_clkA,
    output Busy_clkA,
    input clkB,
    output FlagOut_clkB
);

reg FlagToggle_clkA;
always @(posedge clkA) 
  FlagToggle_clkA <= FlagToggle_clkA ^ (FlagIn_clkA & ~Busy_clkA);

reg [2:0] SyncA_clkB;
always @(posedge clkB) 
  SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};

reg [1:0] SyncB_clkA;
always @(posedge clkA) 
  SyncB_clkA <= {SyncB_clkA[0], SyncA_clkB[2]};

assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);
assign Busy_clkA = FlagToggle_clkA ^ SyncB_clkA[1];

endmodule
