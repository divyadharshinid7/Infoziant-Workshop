`timescale 1ns/1ps
module vending_tb;
    reg clk=0,reset=0,coin5=0,coin10=0,cancel=0;
    wire dispense;
    wire [7:0] change,refund;
    wire [4:0] inserted;
    integer errors=0;
    vending_machine dut(clk,reset,coin5,coin10,cancel,dispense,change,refund,inserted);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day2/waves/vending.vcd"); $dumpvars(0,vending_tb);
        reset=1; tick; reset=0;
        coin10=1; tick; coin10=0; coin5=1; tick; coin5=0;
        if(!dispense || change!=0) errors=errors+1;
        coin10=1; tick; coin10=0; coin10=1; tick; coin10=0;
        if(!dispense || change!=5) errors=errors+1;
        coin5=1; tick; tick; coin5=0;
        cancel=1; tick; cancel=0;
        if(refund!=10 || inserted!=0) errors=errors+1;
        if(errors==0) $display("PASS vending exact payment, change, and cancel refund");
        else $display("FAIL vending errors=%0d",errors);
        $finish;
    end
endmodule
