`timescale 1ns/1ps 
 
module fa_using_dff_tb; 
 
    reg clk; 
    reg rst; 
    reg [3:0] A, B; 
    reg Cin; 
 
    wire [4:0] Q; 
 
    fa_using_dff dut ( 
        .clk(clk), 
        .rst(rst), 
        .A(A), 
        .B(B), 
        .Cin(Cin), 
        .Q(Q) 
    ); 
 
    // Clock generation 
    always #5 clk = ~clk; 
 
    initial begin 
        clk = 0; 
        rst = 1; 
        A = 0; 
        B = 0; 
        Cin = 0; 
 
        #10 rst = 0; 
 
        // Test 1: 3 + 2 = 5 
        A = 4'd3; 
        B = 4'd2; 
        Cin = 0; 
        #10; 
 
        // Test 2: 15 + 1 = 16 
        A = 4'd15; 
        B = 4'd1; 
        Cin = 0; 
        #10; 
 
        // Test 3: 7 + 8 + 1 = 16 
        A = 4'd7; 
        B = 4'd8; 
        Cin = 1; 
        #10; 
 
        $finish; 
    end 
 
    initial begin 
        $monitor("Time=%0t A=%d B=%d Cin=%b Q=%d", 
                  $time, A, B, Cin, Q); 
    end 
 
endmodule