module input_synchronizer (
    input wire clk,
    input wire reset,
    input wire async_in,
    output reg sync_out
);
    reg sync_stage;
    always @(posedge clk) begin
        if (reset) begin
            sync_stage <= 1'b0;
            sync_out <= 1'b0;
        end else begin
            sync_stage <= async_in;
            sync_out <= sync_stage;
        end
    end
endmodule

module counter_debouncer #(
    parameter COUNT_MAX = 4
) (
    input wire clk,
    input wire reset,
    input wire noisy_in,
    output reg clean_out
);
    localparam CW = (COUNT_MAX < 2) ? 1 : $clog2(COUNT_MAX + 1);
    reg [CW-1:0] stable_count;
    always @(posedge clk) begin
        if (reset) begin
            stable_count <= {CW{1'b0}};
            clean_out <= 1'b0;
        end else if (noisy_in == clean_out) begin
            stable_count <= {CW{1'b0}};
        end else if (stable_count == COUNT_MAX - 1) begin
            stable_count <= {CW{1'b0}};
            clean_out <= noisy_in;
        end else begin
            stable_count <= stable_count + 1'b1;
        end
    end
endmodule
