`timescale 1ns/1ps
module shiftreg_lfsr_tb;
    reg clk=0, reset=0, seed_load=0;
    reg [1:0] mode;
    reg left_in,right_in;
    reg [7:0] parallel_in,seed;
    wire [7:0] data,state;
    reg [7:0] seen [0:254];
    integer i,errors=0;
    universal_shift_register sr(clk,reset,mode,left_in,right_in,parallel_in,data);
    lfsr8 l(clk,reset,seed_load,seed,state);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day1/waves/shiftreg_lfsr.vcd"); $dumpvars(0,shiftreg_lfsr_tb);
        reset=1; tick; reset=0;
        mode=3; parallel_in=8'h96; tick;
        if(data!==8'h96) errors=errors+1;
        mode=1; left_in=1; tick;
        if(data!==8'h2d) errors=errors+1;
        mode=2; right_in=1; tick;
        if(data!==8'h96) errors=errors+1;
        mode=0; tick;
        if(data!==8'h96) errors=errors+1;
        for(i=0;i<255;i=i+1) begin
            seen[i]=state;
            if(state==0) errors=errors+1;
            tick;
        end
        if(state!==seen[0]) errors=errors+1;
        for(i=1;i<255;i=i+1) if(seen[i]===seen[0]) errors=errors+1;
        seed_load=1; seed=0; tick; seed_load=0;
        if(state==0) errors=errors+1;
        if(errors==0) $display("PASS shift register/LFSR 255-state period");
        else $display("FAIL shift register/LFSR errors=%0d",errors);
        $finish;
    end
endmodule
