module universal_shift_register (
    input wire clk,
    input wire reset,
    input wire [1:0] mode,
    input wire serial_in_left,
    input wire serial_in_right,
    input wire [7:0] parallel_in,
    output reg [7:0] data
);
    always @(posedge clk) begin
        if (reset)
            data <= 8'd0;
        else begin
            case (mode)
                2'd0: data <= data;
                2'd1: data <= {data[6:0], serial_in_left};
                2'd2: data <= {serial_in_right, data[7:1]};
                2'd3: data <= parallel_in;
            endcase
        end
    end
endmodule
