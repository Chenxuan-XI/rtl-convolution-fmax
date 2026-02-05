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
    parameter int WIDTH = 16,
    parameter int DEPTH = 256
) (
    input  logic                 clk,
    input  logic                 valid_in,
    input  logic [WIDTH-1:0]     x,
    input  logic [$clog2(DEPTH)-1:0] w_addr,
    input  logic [WIDTH-1:0]     b,

    input  logic                 wr_en,
    input  logic [WIDTH-1:0]     wr_data,
    input  logic [$clog2(DEPTH)-1:0] wr_addr,


    output logic [2*WIDTH-1:0]   y,
    output logic                 valid_out
);

    logic [2*WIDTH-1:0] y_s0;
    logic               valid_s0;
    logic [WIDTH-1:0] w_bram;
    logic [WIDTH-1:0] w_q;
    logic [WIDTH-1:0] x_q;
    logic [WIDTH-1:0] b_q;
    logic             valid_in_q;

    BRAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_addr(wr_addr),
        .rd_addr(w_addr),
        .rd_data(w_bram)
    );

    //Reg for x, b, valid_in
    always_ff @(posedge clk) begin
        x_q <= x;
        b_q <= b;
        w_q <= w_bram;
        valid_in_q <= valid_in;
    end

    always_ff @(posedge clk) begin
        valid_s0 <= valid_in_q;
        if (valid_in_q) begin
            // x * w + b in one cycle (mapped to DSP48)
            y_s0 <= (x_q * w_q) + b_q;
        end
    end

    always_ff @(posedge clk) begin
        valid_out <= valid_s0;

        if (valid_s0) begin
            y <= y_s0;
        end
    end

endmodule

