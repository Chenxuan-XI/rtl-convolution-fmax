`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/24 18:55:38
// Design Name: 
// Module Name: conv1x1_1cycle
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


module conv1x1_2stage #(
    parameter int WIDTH = 16
) (
    input  logic                 clk,
    input  logic                 valid_in,
    input  logic [WIDTH-1:0]     x,
    input  logic [WIDTH-1:0]     w,
    input  logic [WIDTH-1:0]     b,

    output logic [2*WIDTH-1:0]   y,
    output logic                 valid_out
);

    logic [2*WIDTH-1:0] y_s0;
    logic               valid_s0;

    always_ff @(posedge clk) begin
        valid_s0 <= valid_in;

        if (valid_in) begin
            // x * w + b in one cycle (mapped to DSP48)
            y_s0 <= (x * w) + b;
        end
    end

    always_ff @(posedge clk) begin
        valid_out <= valid_s0;

        if (valid_s0) begin
            y <= y_s0;
        end
    end

endmodule

