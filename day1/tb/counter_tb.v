`timescale 1ns/1ps
module counter_tb;
    reg clk=0, reset=0, enable=0, up=1, load=0;
    reg [7:0] load_data=0;
    wire [7:0] count;
    integer errors=0;
    up_down_counter dut(clk,reset,enable,up,load,load_data,count);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day1/waves/counter.vcd"); $dumpvars(0,counter_tb);
        reset=1; tick; reset=0;
        if(count!==0) errors=errors+1;
        enable=1; tick; tick;
        if(count!==2) errors=errors+1;
        up=0; tick;
        if(count!==1) errors=errors+1;
        load=1; load_data=8'hfe; tick; load=0;
        if(count!==8'hfe) errors=errors+1;
        reset=1; tick; reset=0;
        if(count!==0) errors=errors+1;
        if(errors==0) $display("PASS counter"); else $display("FAIL counter errors=%0d",errors);
        $finish;
    end
endmodule
