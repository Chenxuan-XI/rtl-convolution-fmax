`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Purpose:
//   Kernel-level top wrapper for spatial parallelism timing exploration
//
// Key properties:
//   - Fixed, minimal top-level I/O
//   - Internal stimulus generation (no IO explosion)
//   - Clean environment for place & route / Fmax study
//
//////////////////////////////////////////////////////////////////////////////////

module top_kernel_wrapper #(
    parameter WIDTH  = 16,
    parameter DEPTH  = 256,
    parameter N_MAC  = 2
)(
    input  logic clk,

    // Optional debug probe only
    output logic [7:0] led
);

    //Internal Signals
    logic valid_in;
    logic [WIDTH-1:0] x_internal;
    logic [WIDTH-1:0] w_internal;
    logic [WIDTH-1:0] b_internal;

    always_ff @(posedge clk) begin
        valid_in   <= 1'b1;                 // Always valid (steady-state)
        x_internal <= x_internal + 1'b1;    // Simple counter stimulus
        w_internal <= 16'h0003;              // Constant weight
        b_internal <= 16'h0001;              // Constant bias
    end

    // Fan-out inputs to parallel MAC array
    logic [WIDTH-1:0] x_array [N_MAC];
    logic [2*WIDTH-1:0] y_array [N_MAC];
    logic valid_out;

    genvar i;
    generate
        for (i = 0; i < N_MAC; i++) begin : GEN_INPUT_FANOUT
            assign x_array[i] = x_internal;
        end
    endgenerate

    // Parallel MAC kernel
    conv1x1_parallel_array #(
        .WIDTH (WIDTH),
        .DEPTH (DEPTH),
        .N_MAC (N_MAC)
    ) dut (
        .clk      (clk),
        .valid_in (valid_in),
        .x        (x_array),
        .w        (w_internal),
        .b        (b_internal),
        .y        (y_array),
        .valid_out(valid_out)
    );

    // Use only one lane as probe
    (* keep = "true" *)
    logic [7:0] led_q;

    always_ff @(posedge clk) begin
        led_q <= y_array[0][7:0];
    end

    assign led = led_q;

    (* keep = "true" *)
    logic [2*WIDTH-1:0] y_probe;

    always_ff @(posedge clk) begin
        y_probe <= y_array[0];
    end

endmodule
