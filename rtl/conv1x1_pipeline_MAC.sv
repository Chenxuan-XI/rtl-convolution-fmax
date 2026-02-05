`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/03 18:57:23
// Design Name: 
// Module Name: conv1x1_pipeline_MAC
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


module conv1x1_pipeline_MAC #(
    parameter WIDTH = 16,
    parameter DEPTH = 256
)(
    input  logic clk,
    input  logic valid_in,
    input  logic [WIDTH-1:0] x,
    input  logic [WIDTH-1:0] w,
    input  logic [WIDTH-1:0] b,

    output logic [2*WIDTH-1:0] y,
    output logic valid_out
);


logic [WIDTH-1:0] x_q;
logic [WIDTH-1:0] b_q;
logic [WIDTH-1:0] w_q;
logic valid_in_q;

always_ff @(posedge clk) begin
    x_q <= x;
    b_q <= b;
    w_q <= w;
    valid_in_q <= valid_in;
end

logic [2*WIDTH-1:0] y_mul;
logic valid_mul;

mul #(
    .WIDTH(WIDTH)
) mul_dut (
    .clk(clk),
    .a(x_q),
    .b(w_q),
    .valid_in(valid_in_q),
    .y(y_mul),
    .valid_out(valid_mul)
);

logic [2*WIDTH-1:0] y_add;
logic valid_add;

add #(
    .WIDTH(WIDTH)
) add_dut (
    .clk(clk),
    .valid_in(valid_mul),
    .in(y_mul),
    .b(b_q),
    .valid_out(valid_add),
    .out(y_add)
);

output_reg #(
    .WIDTH(WIDTH)
) output_reg_dut(
    .clk(clk),
    .valid_in(valid_add),
    .in(y_add),
    .valid_out(valid_out),
    .out(y)
);


endmodule

