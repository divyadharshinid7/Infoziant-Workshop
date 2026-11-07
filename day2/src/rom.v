module sync_rom16x8 #(
    parameter INIT_FILE = "day2/src/rom.hex"
) (
    input wire clk,
    input wire [3:0] address,
    output reg [7:0] data_out
);
    reg [7:0] memory [0:15];
    initial $readmemh(INIT_FILE,memory);
    always @(posedge clk) data_out <= memory[address];
endmodule
