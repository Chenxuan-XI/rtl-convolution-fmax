`timescale 1ns / 1ps

module tb_conv1x1_1cycle;

    localparam int WIDTH = 16;

    logic clk;
    logic valid_in;
    logic [WIDTH-1:0] x, w, b;
    logic [2*WIDTH-1:0] y;
    logic valid_out;

    // DUT
    conv1x1_1cycle #(
        .WIDTH(WIDTH)
    ) dut (
        .clk       (clk),
        .valid_in  (valid_in),
        .x         (x),
        .w         (w),
        .b         (b),
        .y         (y),
        .valid_out (valid_out)
    );

    // ------------------------------------------------------------
    // Clock: 10ns period
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin
        // init
        clk       = 0;
        valid_in  = 0;
        x = 0; w = 0; b = 5;

        // wait a bit
        repeat (2) @(posedge clk);

        // --------------------------------------------------------
        // Case 1: single valid pulse
        // --------------------------------------------------------
        x = 3;
        w = 4;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // Expect valid_out = 1 here
        @(posedge clk);
        if (valid_out !== 1)
            $error("ERROR: valid_out should be 1 (single pulse)");
        if (y !== (3*4 + b))
            $error("ERROR: y mismatch, got %0d", y);

        // --------------------------------------------------------
        // Case 2: back-to-back valids
        // --------------------------------------------------------
        x = 2; w = 7; valid_in = 1;
        @(posedge clk);
        x = 1; w = 9; valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // first result
        @(posedge clk);
        if (valid_out !== 1 || y !== (2*7 + b))
            $error("ERROR: pipeline result 1 wrong");

        // second result
        @(posedge clk);
        if (valid_out !== 1 || y !== (1*9 + b))
            $error("ERROR: pipeline result 2 wrong");

        // --------------------------------------------------------
        // Case 3: idle cycle (hold behavior)
        // --------------------------------------------------------
        @(posedge clk);
        if (valid_out !== 0)
            $error("ERROR: valid_out should be 0 during idle");

        $display("All tests passed.");
        $finish;
    end

endmodule
