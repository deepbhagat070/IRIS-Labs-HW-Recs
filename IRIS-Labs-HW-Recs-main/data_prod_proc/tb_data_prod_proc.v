`timescale 1ns/1ps

module tb_data_prod_proc;

    reg clk = 0;
    reg sensor_clk = 0;

    // 100MHz Processor Clock
    always #5 clk = ~clk;
    // 200MHz Sensor Clock
    always #2.5 sensor_clk = ~sensor_clk;

    // Reset Signals
    reg resetn = 0;
    reg sensor_resetn = 0;

    wire [7:0] pixel;
    wire valid;
    wire ready;
    
    // Test Bench Variable to control the mode
    reg [1:0] tb_mode; 

    // --- INSTANTIATE PROCESSOR ---
    data_proc #(
        .IMG_WIDTH(32) 
    ) data_processing (
        .clk(clk),
        .rstn(resetn),
        .cont(tb_mode),      // Connected to our test variable
        .pixel_in(pixel),    
        .valid_in(valid),    
        .ready_out(ready),   
        .pixel_out(),        
        .valid_out(),
        .ready_in(1'b1)      
    );

    // --- INSTANTIATE PRODUCER ---
    data_producer #(
        .IMAGE_SIZE(1024)
    ) data_producer (
        .sensor_clk(sensor_clk),
        .rst_n(sensor_resetn),
        .ready(ready),
        .pixel(pixel),
        .valid(valid)
    );

    // --- TEST SEQUENCE ---
    initial begin
        // 1. INITIALIZE & RESET
        tb_mode = 2'b00; // Start with Bypass
        resetn = 0;
        sensor_resetn = 0;
        
        #100; // Hold reset
        
        // Release Reset
        resetn = 1;
        sensor_resetn = 1;

        // -------------------------------------------------------
        // TEST 1: MODE 00 (BYPASS)
        // -------------------------------------------------------
        // Expect: Output matches Input
        tb_mode = 2'b00;
        #2000; 

        // -------------------------------------------------------
        // TEST 2: MODE 01 (INVERT)
        // -------------------------------------------------------
        // Expect: Output is Inverted Input
        tb_mode = 2'b01;
        #2000;

        // -------------------------------------------------------
        // TEST 3: RESET CHECK
        // -------------------------------------------------------
        // Expect: Output drops to 00
        resetn = 0; 
        #100;
        resetn = 1; 
        #100;       

        // -------------------------------------------------------
        // TEST 4: MODE 10 (CONVOLUTION)
        // -------------------------------------------------------
        // Expect: Spikes at edges after ~1300ns
        tb_mode = 2'b10;
        #5000; 

        $finish;
    end

endmodule