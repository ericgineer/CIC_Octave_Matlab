`timescale 1ns/1ns

// File containing filter coefficients (does not compile: include in filter module)


wire signed [7:0] mem[0:20];

assign mem[0] = -2;
assign mem[1] = 2;
assign mem[2] = 1;
assign mem[3] = -10;
assign mem[4] = -8;
assign mem[5] = 22;
assign mem[6] = 20;
assign mem[7] = -43;
assign mem[8] = -56;
assign mem[9] = 50;
assign mem[10] = 127;
assign mem[11] = 50;
assign mem[12] = -56;
assign mem[13] = -43;
assign mem[14] = 20;
assign mem[15] = 22;
assign mem[16] = -8;
assign mem[17] = -10;
assign mem[18] = 1;
assign mem[19] = 2;
assign mem[20] = -2;
