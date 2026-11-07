module lfsr8 (
    input wire clk,
    input wire reset,
    input wire seed_load,
    input wire [7:0] seed,
    output reg [7:0] state
);
    wire feedback = state[7] ^ state[5] ^ state[4] ^ state[3];
    always @(posedge clk) begin
        if (reset)
            state <= 8'h01;
        else if (seed_load)
            state <= (seed == 8'd0) ? 8'h01 : seed;
        else
            state <= {state[6:0], feedback};
    end
endmodule
