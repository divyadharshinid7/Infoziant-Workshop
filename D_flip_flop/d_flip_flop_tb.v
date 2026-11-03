`timescale 1ns/1ps

module d_flip_flop_tb;

    // Inputs to the Device Under Test (DUT)
    reg d;
    reg clk;

    // Outputs from the Device Under Test (DUT)
    wire q;

    // Instantiate the Device Under Test (DUT)
    d_flip_flop uut (
        .d(d),
        .clk(clk),
        .q(q)
    );

    // Clock generation: 10ns period (100 MHz clock frequency)
    always begin
        #5 clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        clk = 0;
        d = 0;

        // Wait for 10ns before applying inputs
        #10;
        
        // Test case 1: Drive D to 1
        d = 1;
        #10; // Wait 1 clock cycle
        
        // Test case 2: Drive D to 0
        d = 0;
        #10; // Wait 1 clock cycle

        // Test case 3: Drive D to 1 again
        d = 1;
        #5;  // Change D right before the rising edge to verify setup/hold behavior
        d = 0;
        #15;

        // End simulation
        $finish;
    end

    // Monitor changes in values in the console
    initial begin
        $monitor("Time = %0t | clk = %b | d = %b | q = %b", $time, clk, d, q);
    end

endmodule
