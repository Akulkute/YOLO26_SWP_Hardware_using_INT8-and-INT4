`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 08:24:07 PM
// Design Name: 
// Module Name: baseline_mac
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module baseline_mac (
    input  signed [7:0] a,
    input  signed [7:0] b,
    output signed [15:0] p
);

    // Xilinx-specific attribute to force LUT-based synthesis instead of DSP slices
    (* use_dsp = "no" *) 
    wire signed [15:0] mult_out;

    assign mult_out = a * b;
    assign p = mult_out;

endmodule
