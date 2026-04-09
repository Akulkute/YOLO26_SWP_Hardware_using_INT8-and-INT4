`timescale 1ns / 1ps

module swp_mac (
    input  signed [7:0] a,
    input  signed [7:0] b,
    input               mode_int4, // 0 = Normal INT8 | 1 = Sub-Word 2x INT4
    output reg signed [15:0] p
);

    (* use_dsp = "no" *) 

    // 1. Slice the 8-bit buses into 4-bit chunks
    wire signed [3:0] a_high = a[7:4];
    wire signed [3:0] a_low  = a[3:0];
    wire signed [3:0] b_high = b[7:4];
    wire signed [3:0] b_low  = b[3:0];

    // 2. Perform the isolated INT4 math
    wire signed [7:0] p_high = a_high * b_high;
    wire signed [7:0] p_low  = a_low * b_low;

    // 3. Perform the standard INT8 math
    wire signed [15:0] p_int8 = a * b;

    // 4. The Multiplexer: Choose output based on mode wire
    always @(*) begin
        if (mode_int4 == 1'b1) begin
            p = {p_high, p_low};
        end else begin
            p = p_int8;
        end
    end

endmodule
