`timescale 1ns / 1ps

module tb_swp;

    reg signed [7:0] a;
    reg signed [7:0] b;
    reg mode_int4;
    wire signed [15:0] p;

    swp_mac uut (
        .a(a),
        .b(b),
        .mode_int4(mode_int4),
        .p(p)
    );

    integer file, r;
    reg [31:0] mode_read; 
    reg [31:0] expected_out;
    integer error_count;
    integer test_count;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_swp);

        a = 0; b = 0; mode_int4 = 0;
        error_count = 0; test_count = 0;

        file = $fopen("test_vectors.txt", "r");
        if (file == 0) begin
            $display("ERROR: Could not open test_vectors.txt");
            $finish;
        end

        $display("--- Starting SWP MAC Verification ---");

        while (!$feof(file)) begin
            r = $fscanf(file, "%d %h %h %h\n", mode_read, a, b, expected_out);
            if (r == 4) begin
                test_count = test_count + 1;
                mode_int4 = mode_read[0]; 
                #10; 
                
                if (p !== expected_out) begin
                    $display("FAIL: Mode=%b A=%h B=%h | Expected=%h, Got=%h", mode_int4, a, b, expected_out, p);
                    error_count = error_count + 1;
                end else begin
                    $display("PASS: Mode=%b A=%h B=%h | Out=%h", mode_int4, a, b, p);
                end
            end
        end

        $fclose(file);
        $display("-----------------------------");
        $display("Total Tests Run: %d", test_count);
        $display("Total Errors: %d", error_count);
        
        if (error_count == 0 && test_count > 0)
            $display(">>> SUCCESS: Day 8 SWP Verification Passed! <<<");
        else
            $display(">>> FAILED: Check your bit-slicing logic. <<<");

        $finish;
    end
endmodule
