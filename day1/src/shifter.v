module barrel_shifter (
    input wire [31:0] data_in,
    input wire [4:0] amount,
    input wire [1:0] mode,
    output reg [31:0] data_out
);
    always @(*) begin
        case (mode)
            2'd0: data_out = data_in << amount;
            2'd1: data_out = data_in >> amount;
            2'd2: data_out = $signed(data_in) >>> amount;
            default: data_out = 32'd0;
        endcase
    end
endmodule
