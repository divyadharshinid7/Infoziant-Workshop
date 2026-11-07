module up_down_counter (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire up,
    input wire load,
    input wire [7:0] load_data,
    output reg [7:0] count
);
    always @(posedge clk) begin
        if (reset)
            count <= 8'd0;
        else if (load)
            count <= load_data;
        else if (enable)
            count <= up ? count + 8'd1 : count - 8'd1;
    end
endmodule
