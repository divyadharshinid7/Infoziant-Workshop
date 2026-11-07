module edge_detector (
    input wire clk,
    input wire reset,
    input wire signal_in,
    output wire rising_pulse
);
    reg signal_d;
    always @(posedge clk) begin
        if (reset)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end
    assign rising_pulse = signal_in & ~signal_d;
endmodule
