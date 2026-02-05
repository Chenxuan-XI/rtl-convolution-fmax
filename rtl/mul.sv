`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/03 12:57:24
// Design Name: 
// Module Name: mul
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


module mul #(
    parameter WIDTH = 16
) (
    input  logic clk,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic valid_in,

    output logic [2*WIDTH-1:0] y,
    output logic valid_out
);

// (* use_dsp = "yes" *)
always_ff@ (posedge clk) begin
    valid_out <= valid_in;
    if(valid_in) begin
        y <= a * b; //MREG = 1
    end
end

endmodule
