`timescale 1ns/1ps

module BRAM_tb;

    // ----------------------------
    // Parameters
    // ----------------------------
    localparam int WIDTH = 32;
    localparam int DEPTH = 256;
    localparam int AW    = $clog2(DEPTH);

    // ----------------------------
    // DUT signals
    // ----------------------------
    logic clk;
    logic wr_en;
    logic [WIDTH-1:0] wr_data;
    logic [AW-1:0] wr_addr;
    logic [AW-1:0] rd_addr;
    logic [WIDTH-1:0] rd_data;

    // ----------------------------
    // Instantiate DUT
    // ----------------------------
    BRAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk     (clk),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .wr_addr (wr_addr),
        .rd_addr (rd_addr),
        .rd_data (rd_data)
    );

    // ----------------------------
    // Clock generation: 100 MHz
    // ----------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ----------------------------
    // Test sequence
    // ----------------------------
    initial begin
        // Default values
        wr_en   = 0;
        wr_data = 0;
        wr_addr = 0;
        rd_addr = 0;

        // Wait a few cycles
        repeat (2) @(posedge clk);

        // =====================================================
        // Test 1: Single write -> read back
        // =====================================================
        $display("==== Test 1: single write / read ====");

        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 8'd5;
        wr_data <= 32'hDEADBEEF;

        @(posedge clk);
        wr_en   <= 0;
        rd_addr <= 8'd5;

        @(posedge clk); // rd_data valid here
        $display("Read addr 5: rd_data = 0x%08X", rd_data);

        // =====================================================
        // Test 2: Multiple writes, multiple reads
        // =====================================================
        $display("==== Test 2: multiple writes / reads ====");

        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 8'd10;
        wr_data <= 32'h11111111;

        @(posedge clk);
        wr_addr <= 8'd11;
        wr_data <= 32'h22222222;

        @(posedge clk);
        wr_addr <= 8'd12;
        wr_data <= 32'h33333333;

        @(posedge clk);
        wr_en <= 0;

        // Read back
        @(posedge clk);
        rd_addr <= 8'd10;

        @(posedge clk);
        $display("Read addr 10: rd_data = 0x%08X", rd_data);

        @(posedge clk);
        rd_addr <= 8'd11;

        @(posedge clk);
        $display("Read addr 11: rd_data = 0x%08X", rd_data);

        @(posedge clk);
        rd_addr <= 8'd12;

        @(posedge clk);
        $display("Read addr 12: rd_data = 0x%08X", rd_data);

        // =====================================================
        // Test 3: Read & write same address in same cycle
        // =====================================================
        $display("==== Test 3: read/write same address ====");

        // First initialize address 20
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 8'd20;
        wr_data <= 32'hAAAA_AAAA;

        @(posedge clk);
        wr_en <= 0;

        // Now read and write same address
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 8'd20;
        wr_data <= 32'hBBBB_BBBB;
        rd_addr <= 8'd20;

        @(posedge clk);
        wr_en <= 0;

        @(posedge clk);
        $display("Read addr 20 after write: rd_data = 0x%08X", rd_data);

        // =====================================================
        // End simulation
        // =====================================================
        $display("==== Testbench finished ====");
        #20;
        $finish;
    end

endmodule
