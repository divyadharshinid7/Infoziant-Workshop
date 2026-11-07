module round_robin_arbiter4 (
    input wire clk,
    input wire reset,
    input wire [3:0] request,
    output reg [3:0] grant
);
    reg [1:0] priority;
    reg [3:0] next_grant;
    integer offset, index;

    always @(*) begin
        next_grant=4'b0;
        for(offset=0;offset<4;offset=offset+1) begin
            index=(priority+offset)&3;
            if(next_grant==0 && request[index])
                next_grant=4'b0001<<index;
        end
    end

    always @(posedge clk) begin
        if(reset) begin grant<=0; priority<=0; end
        else if(grant!=0) begin
            if((grant & request)==0) begin
                case(grant)
                    4'b0001: priority<=1;
                    4'b0010: priority<=2;
                    4'b0100: priority<=3;
                    default: priority<=0;
                endcase
                grant<=0;
            end
        end else grant<=next_grant;
    end
endmodule
