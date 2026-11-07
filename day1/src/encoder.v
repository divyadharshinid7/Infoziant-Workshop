module priority_encoder_casez (
    input wire [7:0] request,
    output reg valid,
    output reg [2:0] code
);
    always @(*) begin
        valid = 1'b1;
        casez (request)
            8'b1???????: code = 3'd7;
            8'b01??????: code = 3'd6;
            8'b001?????: code = 3'd5;
            8'b0001????: code = 3'd4;
            8'b00001???: code = 3'd3;
            8'b000001??: code = 3'd2;
            8'b0000001?: code = 3'd1;
            8'b00000001: code = 3'd0;
            default: begin code = 3'd0; valid = 1'b0; end
        endcase
    end
endmodule

module priority_encoder_if (
    input wire [7:0] request,
    output reg valid,
    output reg [2:0] code
);
    always @(*) begin
        valid = 1'b1;
        if      (request[7]) code = 3'd7;
        else if (request[6]) code = 3'd6;
        else if (request[5]) code = 3'd5;
        else if (request[4]) code = 3'd4;
        else if (request[3]) code = 3'd3;
        else if (request[2]) code = 3'd2;
        else if (request[1]) code = 3'd1;
        else if (request[0]) code = 3'd0;
        else begin code = 3'd0; valid = 1'b0; end
    end
endmodule
