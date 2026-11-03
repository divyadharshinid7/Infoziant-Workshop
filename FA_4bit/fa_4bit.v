`timescale 1ns/1ps

module fa_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output reg  [3:0] Sum,
    output reg        Cout
);

    // Internal variable to hold the carry signals
    reg [4:0] c; 

    always @(*) begin
        c[0] = Cin;
        
        // Bit 0
        Sum[0] = A[0] ^ B[0] ^ c[0];
        c[1]   = (A[0] & B[0]) | (c[0] & (A[0] ^ B[0]));
        
        // Bit 1
        Sum[1] = A[1] ^ B[1] ^ c[1];
        c[2]   = (A[1] & B[1]) | (c[1] & (A[1] ^ B[1]));
        
        // Bit 2
        Sum[2] = A[2] ^ B[2] ^ c[2];
        c[3]   = (A[2] & B[2]) | (c[2] & (A[2] ^ B[2]));
        
        // Bit 3
        Sum[3] = A[3] ^ B[3] ^ c[3];
        c[4]   = (A[3] & B[3]) | (c[3] & (A[3] ^ B[3]));
        
        // Final Carry-Out
        Cout   = c[4];
    end

endmodule