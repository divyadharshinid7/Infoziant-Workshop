`timescale 1ns/1ps
module debounce_tb;
    reg clk=0,reset=0,async_in=0;
    wire synchronized,clean,pulse;
    integer pulse_count=0,errors=0,i;
    input_synchronizer sync(clk,reset,async_in,synchronized);
    counter_debouncer #(.COUNT_MAX(3)) db(clk,reset,synchronized,clean);
    edge_detector ed(clk,reset,clean,pulse);
    always #5 clk=~clk;
    always @(posedge clk) if(pulse) pulse_count=pulse_count+1;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day1/waves/debounce.vcd"); $dumpvars(0,debounce_tb);
        reset=1; tick; reset=0;
        async_in=1; tick; async_in=0; tick;
        async_in=1; tick; async_in=0; tick;
        async_in=1;
        repeat(8) tick;
        if(clean!==1 || pulse_count!=1) errors=errors+1;
        repeat(5) tick;
        if(pulse_count!=1) errors=errors+1;
        async_in=0; repeat(8) tick;
        if(clean!==0) errors=errors+1;
        if(errors==0) $display("PASS synchronizer/debouncer/edge detector");
        else $display("FAIL debounce errors=%0d pulses=%0d",errors,pulse_count);
        $finish;
    end
endmodule
