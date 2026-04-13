`timescale 1ns / 1ps

module yolo_accel_sync (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] data_in_a,
    input wire [7:0] data_in_b,
    output reg [15:0] result_p,
    output reg done,
    output reg mode_int4 
);

    // --- Standard Verilog State Parameters ---
    // Using localparam instead of typedef enum for universal compatibility
    localparam IDLE   = 2'b00;
    localparam PHASE1 = 2'b01;
    localparam PHASE2 = 2'b10;
    localparam FINISH = 2'b11;

    reg [1:0] current_state, next_state;
    reg [7:0] cycle_count;

    // --- State Transition & Counter Logic ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            cycle_count   <= 8'd0;
        end else begin
            current_state <= next_state;
            
            // Increment counter only during active processing
            if (next_state == PHASE1 || next_state == PHASE2) begin
                if (current_state != next_state) 
                    cycle_count <= 8'd0; // Reset counter on state entry
                else 
                    cycle_count <= cycle_count + 1'b1;
            end else begin
                cycle_count <= 8'd0;
            end
        end
    end

    // --- Next State Logic (Combinational) ---
    always @(*) begin
        case (current_state)
            IDLE:   next_state = (start) ? PHASE1 : IDLE;
            
            // Stay in PHASE1 for 256 cycles (0 to 255)
            PHASE1: next_state = (cycle_count == 8'd255) ? PHASE2 : PHASE1;
            
            // Stay in PHASE2 for 5 cycles (0 to 4)
            PHASE2: next_state = (cycle_count == 8'd4)   ? FINISH : PHASE2;
            
            FINISH: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // --- Synchronous Math & Output Logic ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result_p  <= 16'd0;
            mode_int4 <= 1'b0;
            done      <= 1'b0;
        end else begin
            case (next_state) // Looking at next_state reduces latency
                IDLE: begin
                    done <= 1'b0;
                    mode_int4 <= 1'b0;
                end

                PHASE1: begin
                    mode_int4 <= 1'b0;
                    result_p  <= $signed(data_in_a) * $signed(data_in_b);
                    done      <= 1'b0;
                end

                PHASE2: begin
                    mode_int4 <= 1'b1;
                    // Sub-Word Parallel (SWP) Math: Two 4-bit mults in one cycle
                    result_p[15:8] <= $signed(data_in_a[7:4]) * $signed(data_in_b[7:4]);
                    result_p[7:0]  <= $signed(data_in_a[3:0]) * $signed(data_in_b[3:0]);
                    done           <= 1'b0;
                end

                FINISH: begin
                    done <= 1'b1;
                end
                
                default: done <= 1'b0;
            endcase
        end
    end

endmodule
