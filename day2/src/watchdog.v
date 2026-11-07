module watchdog_timer #(
    parameter WIDTH = 16
) (
    input wire clk,
    input wire reset,
    input wire kick,
    input wire enable,
    input wire [WIDTH-1:0] timeout_value,
    output reg reset_pulse,
    output reg [WIDTH-1:0] count
);
    always @(posedge clk) begin
        if(reset) begin count<=timeout_value; reset_pulse<=0; end
        else begin
            reset_pulse<=0;
            if(!enable) count<=timeout_value;
            else if(kick) count<=timeout_value;
            else if(count>1) count<=count-1'b1;
            else if(count==1) begin count<=0; reset_pulse<=1; end
        end
    end
endmodule
