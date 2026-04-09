`timescale 1ns / 1ps

module baseline_mac (
    input  signed [7:0] a,
    input  signed [7:0] b,
    output signed [15:0] p
);

    (* use_dsp = "no" *) 
    wire signed [15:0] mult_out;

    assign mult_out = a * b;
    assign p = mult_out;

endmodule
