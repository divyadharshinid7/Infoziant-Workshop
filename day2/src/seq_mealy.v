module seq_mealy (
    input wire clk,
    input wire reset,
    input wire serial_in,
    output wire detected
);
    reg [1:0] state, next_state;
    localparam S0=0, S1=1, S2=2, S3=3;
    always @(posedge clk) begin
        if (reset) state <= S0;
        else state <= next_state;
    end
    always @(*) begin
        next_state = S0;
        case (state)
            S0: next_state = serial_in ? S1 : S0;
            S1: next_state = serial_in ? S1 : S2;
            S2: next_state = serial_in ? S3 : S0;
            S3: next_state = serial_in ? S1 : S2;
            default: next_state = S0;
        endcase
    end
    assign detected = (state == S3) && serial_in;
endmodule
