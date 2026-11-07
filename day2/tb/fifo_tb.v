`timescale 1ns/1ps
module fifo_tb;
    reg clk=0,reset=0,write_enable=0,read_enable=0;
    reg [7:0] data_in=0;
    wire [7:0] data_out;
    wire full,empty;
    wire [4:0] count;
    integer i,errors=0;
    synchronous_fifo dut(clk,reset,write_enable,read_enable,data_in,data_out,full,empty,count);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day2/waves/fifo.vcd"); $dumpvars(0,fifo_tb);
        reset=1; tick; reset=0;
        for(i=0;i<16;i=i+1) begin write_enable=1; data_in=i; tick; end
        write_enable=0;
        if(!full || count!=16) errors=errors+1;
        data_in=8'hff; write_enable=1; tick; write_enable=0;
        if(count!=16) errors=errors+1;
        read_enable=1; tick;
        if(data_out!==0 || !full) begin
            if(data_out!==0 || count!=15) errors=errors+1;
        end
        write_enable=1; data_in=8'hee; tick; write_enable=0; read_enable=0;
        if(count!=15) errors=errors+1;
        read_enable=1;
        if(data_out!==1) errors=errors+1;
        for(i=2;i<16;i=i+1) begin tick; if(data_out!==i) errors=errors+1; end
        tick;
        if(data_out!==8'hee) errors=errors+1;
        read_enable=0;
        if(!empty || count!=0) errors=errors+1;
        read_enable=1; tick; read_enable=0;
        if(count!=0) errors=errors+1;
        if(errors==0) $display("PASS FIFO fill/full/drain/overflow/underflow/simultaneous");
        else $display("FAIL FIFO errors=%0d count=%0d",errors,count);
        $finish;
    end
endmodule
