`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/29 19:42:38
// Design Name: 
// Module Name: BRAM
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


module BRAM #(
    parameter WIDTH = 32,
    parameter DEPTH = 256
) (
    input  logic clk,
    input  logic wr_en,
    input  logic [WIDTH-1:0] wr_data,
    input  logic [$clog2(DEPTH)-1:0] wr_addr,
    input  logic [$clog2(DEPTH)-1:0] rd_addr,
    output logic [WIDTH-1:0] rd_data
    );

    (* ram_style = "block" *)
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Synchronous Read
    always_ff @(posedge clk) begin
        rd_data <= mem[rd_addr];
    end

    // Synchronous Write
    always_ff @(posedge clk) begin
        if(wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // Read the old data if change wr and rd data synchronously
endmodule
