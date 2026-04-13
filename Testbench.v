`timescale 1ns / 1ps

module baseline_mac_tb();
    // Use 'logic' for SystemVerilog - it's more flexible than reg/wire
    logic signed [7:0] a_tb;
    logic signed [7:0] b_tb;
    logic signed [15:0] p_tb;
    
    // Clock only used for "Machine Cycle" counting
    logic clk;
    integer cycle_count = 0;

    // --- Instantiate the Baseline Module ---
    // Ensure this matches the name in your baseline_mac.v exactly
    baseline_mac uut (
        .a(a_tb),
        .b(b_tb),
        .p(p_tb)
    );

    // 100MHz Clock (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        a_tb = 0; 
        b_tb = 0;
        #20; // Global Reset time
        
        $display("--- Starting Baseline Serial Comparison ---");

        // PHASE 1: Feature Extraction (8-bit)
        // We simulate 256 pixels to match your NPU's timing
        repeat (256) begin
            @(posedge clk);
            a_tb = $random % 127;
            b_tb = 8'h02;
            cycle_count++;
        end

        // PHASE 2: Coordinate Processing (The Bottleneck)
        // Your SWP NPU did 10 coordinates in 5 cycles.
        // This baseline MUST take 10 cycles because it processes one by one.
        repeat (10) begin
            @(posedge clk);
            a_tb = $random % 15; // 4-bit coord
            b_tb = 8'h03;        // weight
            cycle_count++;
        end

        $display("Baseline Finished. Total Cycles: %0d", cycle_count);
        $finish;
    end
endmodule
