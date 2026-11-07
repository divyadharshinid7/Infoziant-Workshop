module decoder3to8 (
    input wire enable,
    input wire [2:0] code,
    output reg [7:0] decoded
);
    always @(*) begin
        decoded = 8'd0;
        if (enable)
            decoded[code] = 1'b1;
    end
endmodule
