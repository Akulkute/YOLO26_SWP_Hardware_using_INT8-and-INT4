`timescale 1ns / 1ps

module Swp_mac_tb();

    // 1. Declare Signals (Regs for inputs, Wires for outputs)
    reg clk;
    reg reset;
    reg start;
    reg [7:0] data_in_a;
    reg [7:0] data_in_b;
    
    wire [15:0] result_p;
    wire done;
    wire mode_int4;

    // 2. Instantiate the Unit Under Test (UUT)
    yolo_accel_sync uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .result_p(result_p),
        .done(done),
        .mode_int4(mode_int4)
    );

    // 3. Clock Generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Stimulus Logic
    initial begin
        // Initialize
        reset = 1;
        start = 0;
        data_in_a = 0;
        data_in_b = 0;
        
        #20 reset = 0; // Release reset
        #10 start = 1; // Pulse start
        #10 start = 0;

        // Simulate Phase 1 (Feeding dummy pixel data)
        repeat (256) begin
            @(posedge clk);
            data_in_a = $random % 128; // Random pixel
            data_in_b = 8'h02;         // Fixed weight
        end

        // Simulate Phase 2 (Feeding packed coordinates)
        repeat (5) begin
            @(posedge clk);
            data_in_a = 8'h93; // Pack X=9, Y=3
            data_in_b = 8'h23; // Pack weights
        end

        // Wait for hardware to finish
        wait(done);
        #100;
        $display("Simulation Complete. Machine Cycles calculated.");
        $finish;
    end

endmodule
