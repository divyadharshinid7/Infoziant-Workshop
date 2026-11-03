module register( 
    input wire clk, 
    input wire rst, 
    input wire [7:0] D, 
    output reg [7:0] Q 
); 
 
    always @(posedge clk or posedge rst) begin 
        if (rst) 
            Q <= 8'b00000000; 
        else 
            Q <= D; 
    end 
 
endmodule 