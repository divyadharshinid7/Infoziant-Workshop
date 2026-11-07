`timescale 1ns/1ps
module arbiter_tb;
    reg clk=0,reset=0;
    reg [3:0] request=0;
    wire [3:0] grant;
    integer counts[0:3];
    integer i,errors=0;
    round_robin_arbiter4 dut(clk,reset,request,grant);
    always #5 clk=~clk;
    initial begin
        $dumpfile("day2/waves/arbiter.vcd"); $dumpvars(0,arbiter_tb);
        for(i=0;i<4;i=i+1) counts[i]=0;
        reset=1; @(posedge clk); #1; reset=0; request=4'b1111;
        for(i=0;i<24;i=i+1) begin
            @(posedge clk); #1;
            if(grant!=0) begin
                if((grant & (grant-1))!=0) errors=errors+1;
                case(grant)
                    1: counts[0]=counts[0]+1;
                    2: counts[1]=counts[1]+1;
                    4: counts[2]=counts[2]+1;
                    8: counts[3]=counts[3]+1;
                    default: errors=errors+1;
                endcase
                request=request & ~grant;
            end else request=4'b1111;
        end
        for(i=0;i<4;i=i+1)
            if(counts[i]<1 || counts[i]>counts[(i+1)%4]+1 || counts[(i+1)%4]>counts[i]+1)
                errors=errors+1;
        if(errors==0) $display("PASS round-robin fairness grants=%0d,%0d,%0d,%0d",counts[0],counts[1],counts[2],counts[3]);
        else $display("FAIL arbiter errors=%0d grants=%0d,%0d,%0d,%0d",errors,counts[0],counts[1],counts[2],counts[3]);
        $finish;
    end
endmodule
