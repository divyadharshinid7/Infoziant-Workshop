`timescale 1ns/1ps
module sequence_tb;
    reg clk=0, reset=0, serial_in=0;
    wire moore_detected,mealy_detected;
    integer moore_count=0,mealy_count=0,errors=0,i;
    reg [15:0] stream;
    reg [4:0] length;
    seq_moore m(clk,reset,serial_in,moore_detected);
    seq_mealy y(clk,reset,serial_in,mealy_detected);
    always #5 clk=~clk;
    task send(input [15:0] bits,input [4:0] n);
        begin
            stream=bits; length=n;
            for(i=n-1;i>=0;i=i-1) begin
                @(negedge clk); serial_in=stream[i];
                @(posedge clk); #1;
                if(moore_detected) moore_count=moore_count+1;
                if(mealy_detected) mealy_count=mealy_count+1;
            end
        end
    endtask
    initial begin
        $dumpfile("day2/waves/sequence.vcd"); $dumpvars(0,sequence_tb);
        reset=1; @(posedge clk); #1; reset=0;
        send(16'b1011,4);
        send(16'b1011011,7);
        send(16'b000000,6);
        if(moore_count!=3 || mealy_count!=3) errors=errors+1;
        if(errors==0) $display("PASS sequence detector; overlapping 1011 detections=%0d",moore_count);
        else $display("FAIL sequence detector errors=%0d Moore=%0d Mealy=%0d",errors,moore_count,mealy_count);
        $finish;
    end
endmodule
