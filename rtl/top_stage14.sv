`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/03 22:40:00
// Design Name: 
// Module Name: top_stage14
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


module top_stage14 #(
    parameter WIDTH = 16,
    parameter DEPTH = 256,
    parameter N_MAC  = 2
)(
    input  logic clk,    
    output logic valid_out,
    output logic [7:0] led
);

logic [WIDTH-1:0] x [N_MAC];
logic [WIDTH-1:0] b;
logic [WIDTH-1:0] w;
logic [2*WIDTH-1:0] y [N_MAC];
logic valid_in;

assign valid_in = 1'b1;

integer i;
always_ff @(posedge clk) begin
    w <= 16'h0003;
    b <= 16'h0001;
    for (i = 0; i < N_MAC; i++) begin
        x[i] <= i;
    end
end

conv1x1_parallel_array #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .N_MAC(N_MAC)
) dut (
    .clk(clk),
    .valid_in(valid_in),
    .x(x),
    .w(w),
    .b(b),
    .y(y),
    .valid_out(valid_out)
);

// (* DONT_TOUCH = "true" *) logic [7:0] tap0;
// (* DONT_TOUCH = "true" *) logic [7:0] tap1;

// always_ff @(posedge clk) begin
//     tap0 <= y[0][7:0];
//     tap1 <= tap0;
// end


// (* keep = "true" *) logic [7:0] led_q;

// always_ff @(posedge clk) begin
//     led_q <= y[0][7:0];
// end

// assign led = led_q;


endmodule
