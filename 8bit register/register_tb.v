`timescale 1ns/1ps 
 
module register_tb; 
 
    reg clk; 
    reg rst; 
    reg [7:0] D; 
    wire [7:0] Q; 
 
    register dut ( 
        .clk(clk), 
        .rst(rst), 
        .D(D), 
        .Q(Q) 
    ); 
 
    // Clock generation 
    always #5 clk = ~clk; 
 
    initial begin 
        clk = 0; 
        rst = 1; 
        D = 8'b00000000; 
 
        #10 rst = 0; 
 
        // Test 1 
        D = 8'b10101010; 
        #10; 
 
        // Test 2 
        D = 8'b11110000; 
        #10; 
 
        // Test 3 
        D = 8'b01010101; 
        #10; 
 
        // Test 4 
        D = 8'b11111111; 
        #10; 
 
        $finish; 
    end 
 
    initial begin 
        $monitor("Time=%0t D=%b Q=%b", 
                  $time, D, Q); 
    end 
 
endmodule