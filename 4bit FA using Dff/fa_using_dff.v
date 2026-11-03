module fa_using_dff ( 
    input  wire       clk, 
    input  wire       rst, 
    input  wire [3:0] A, 
    input  wire [3:0] B, 
    input  wire       Cin, 
    output reg  [4:0] Q 
); 
 
    wire [4:0] sum; 
 
    // Combinational full adder 
    assign sum = A + B + Cin; 
 
    // D flip-flop 
    always @(posedge clk or posedge rst) begin 
        if (rst) 
            Q <= 5'b00000; 
        else 
            Q <= sum; 
    end 
 
endmodule 