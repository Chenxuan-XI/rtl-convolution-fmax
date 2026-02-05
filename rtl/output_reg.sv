`timescale 1ns / 1ps

module output_reg #(
    parameter WIDTH = 16
) (
    input  logic clk,
    input  logic valid_in,
    input  logic [2*WIDTH-1:0] in,

    output logic valid_out,
    output logic [2*WIDTH-1:0] out
);

always_ff @(posedge clk) begin
    valid_out <= valid_in;
    if(valid_in) begin
        out <= in;
    end
end

endmodule