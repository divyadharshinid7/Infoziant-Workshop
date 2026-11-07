`timescale 1ns/1ps
module atm_tb;
    reg clk=0,reset=0,card_insert=0,submit_pin=0,check_balance=0,withdraw=0,card_remove=0;
    reg [15:0] entered_pin=0;
    reg [31:0] withdraw_amount=0;
    wire [31:0] balance;
    wire balance_valid,dispense_cash,insufficient_funds,locked;
    wire [2:0] state;
    integer errors=0,i;
    atm_controller dut(clk,reset,card_insert,submit_pin,entered_pin,check_balance,withdraw,
        withdraw_amount,card_remove,balance,balance_valid,dispense_cash,insufficient_funds,locked,state);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day2/waves/atm.vcd"); $dumpvars(0,atm_tb);
        reset=1; tick; reset=0;
        card_insert=1; tick; card_insert=0;
        entered_pin=16'h1234; submit_pin=1; tick; submit_pin=0;
        check_balance=1; tick; check_balance=0;
        if(!balance_valid || balance!=1000) errors=errors+1;
        withdraw_amount=300; withdraw=1; tick; withdraw=0;
        if(!dispense_cash || balance!=700) errors=errors+1;
        withdraw_amount=701; withdraw=1; tick; withdraw=0;
        if(!insufficient_funds || balance!=700) errors=errors+1;
        card_remove=1; tick; card_remove=0;
        card_insert=1; tick; card_insert=0;
        entered_pin=0; submit_pin=1;
        for(i=0;i<3;i=i+1) tick;
        submit_pin=0;
        if(!locked || state!=3) errors=errors+1;
        if(errors==0) $display("PASS ATM PIN, balance, withdrawal, insufficient funds, lockout");
        else $display("FAIL ATM errors=%0d state=%0d",errors,state);
        $finish;
    end
endmodule
