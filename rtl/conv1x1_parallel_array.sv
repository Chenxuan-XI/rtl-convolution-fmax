`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/03 19:03:11
// Design Name: 
// Module Name: conv1x1_parallel_array
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


module conv1x1_parallel_array # (
    parameter WIDTH  = 16,
    parameter DEPTH = 256,
    parameter N_MAC  = 2,
    parameter OFFSET_X = 1  //0: all MAC same x; 1: MAC_x[i+1] = MAC_x[i] + 1
)(
    input  logic clk,
    input  logic valid_in,

    input  logic [WIDTH-1:0] x_internal,
    // input  logic [$clog2(DEPTH)-1:0] w_addr,            // shared value for all MACs
    input  logic [WIDTH-1:0] w,
    input  logic [WIDTH-1:0] b,            // shared value for all MACs

    output logic [2*WIDTH-1:0] y [N_MAC],
    output logic valid_out
);

logic [WIDTH-1:0] x [N_MAC];

genvar i;
generate
    for (i = 0; i < N_MAC; i++) begin
        assign x[i] = OFFSET_X ? (x_internal + i) : x_internal;
    end
endgenerate


// logic wr_en = 1'b0;
// logic [WIDTH-1:0] wr_data = '0;
// logic [$clog2(DEPTH)-1:0] wr_addr = '0;
// logic [WIDTH-1:0] w_bram;

// BRAM #(
//     .WIDTH(WIDTH),
//     .DEPTH(DEPTH)
// ) dut (
//     .clk(clk),
//     .wr_en(wr_en),
//     .wr_data(wr_data),
//     .wr_addr(wr_addr),
//     .rd_addr(w_addr),
//     .rd_data(w_bram)
// );

// logic [WIDTH-1:0] x_q [N_MAC];
// logic [WIDTH-1:0] b_q;
// logic [WIDTH-1:0] w_q;
// logic valid_in_q;

// always_ff @(posedge clk) begin
//     x_q <= x;
//     b_q <= b;
//     w_q <= w_bram;
//     valid_in_q <= valid_in;
// end

logic valid_out_array [N_MAC];

genvar j;
generate
    for(j=0; j < N_MAC; j++) begin : GEN_MAC
        conv1x1_pipeline_MAC #(
            .WIDTH(WIDTH),
            .DEPTH(DEPTH)
        ) dut (
            .clk(clk),
            .valid_in(valid_in),
            .x(x[j]),
            .w(w),
            .b(b),
            .y(y[j]),
            .valid_out(valid_out_array[j])
        );
    end
endgenerate

assign valid_out = valid_out_array[0];


endmodule
