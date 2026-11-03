`timescale 1ns/1ps

module fa_4bit_tb;

    // Inputs declared as registers
    reg [3:0] A;
    reg [3:0] B;
    reg       Cin;

    // Outputs declared as wires
    wire [3:0] Sum;
    wire       Cout;

    // Instantiate the Unit Under Test (UUT)
    fa_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        // Monitor block to display results automatically in the console when signals change
        $monitor("Time = %0dns | A = %b (%0d) | B = %b (%0d) | Cin = %b | Sum = %b (%0d) | Cout = %b", 
                 $time, A, A, B, B, Cin, Sum, Sum, Cout);

        // Test Case 1: Standard addition without a carry-in (5 + 3 = 8)
        A = 4'b0101; B = 4'b0011; Cin = 1'b0; #10;
        
        // Test Case 2: Standard addition with a carry-in (10 + 2 + 1 = 13)
        A = 4'b1010; B = 4'b0010; Cin = 1'b1; #10;
        
        // Test Case 3: Maximum boundary limit causing a carry-out (15 + 1 = 16 -> Sum=0, Cout=1)
        A = 4'b1111; B = 4'b0001; Cin = 1'b0; #10;
        
        // Test Case 4: Absolute maximum configuration (15 + 15 + 1 = 31 -> Sum=15, Cout=1)
        A = 4'b1111; B = 4'b1111; Cin = 1'b1; #10;
        
        // Test Case 5: Zero condition
        A = 4'b0000; B = 4'b0000; Cin = 1'b0; #10;

        $finish; // End the simulation run
    end

endmodule
