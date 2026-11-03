`timescale 1ns/1ps 
 
module atm_controller_tb; 
 
    reg clk, rst; 
    reg card, pin_enter, withdraw, amount_enter; 
    reg [15:0] pin, amount; 
 
    wire dispense, insufficient; 
    wire [15:0] balance; 
 
    atm_controller dut ( 
        .clk(clk), 
        .rst(rst), 
        .card(card), 
        .pin_enter(pin_enter), 
        .pin(pin), 
        .withdraw(withdraw), 
        .amount_enter(amount_enter), 
        .amount(amount), 
        .dispense(dispense), 
        .insufficient(insufficient), 
        .balance(balance) 
    ); 
 
    // Clock generation 
    always #5 clk = ~clk; 
 
    initial begin 
        clk = 0; 
        rst = 1; 
 
        card = 0; 
        pin_enter = 0; 
        pin = 0; 
        withdraw = 0; 
        amount_enter = 0; 
        amount = 0; 
 
        // Reset 
        #10 rst = 0; 
 
        // Insert card 
        #10 card = 1; 
        #10 card = 0; 
 
        // Enter correct PIN 
        pin = 1234; 
        pin_enter = 1; 
        #10 pin_enter = 0; 
 
        // Select withdrawal 
        withdraw = 1; 
        #10 withdraw = 0; 
 
        // Enter amount: Rs.1000 
        amount = 1000; 
        amount_enter = 1; 
        #10 amount_enter = 0; 
 
        // Wait for cash dispensing 
        #10; 
 
        // Second transaction: insufficient balance 
        card = 1; 
        #10 card = 0; 
 
        pin = 1234; 
        pin_enter = 1; 
        #10 pin_enter = 0; 
 
        withdraw = 1; 
        #10 withdraw = 0; 
 
        amount = 6000; 
        amount_enter = 1; 
        #10 amount_enter = 0; 
 
        #10; 
 
        $finish; 
    end 
 
    initial begin 
        $monitor( 
            "Time=%0t Card=%b PIN=%d Amount=%d Balance=%d Dispense=%b Error=%b", 
            $time, card, pin, amount, balance, 
            dispense, insufficient 
        ); 
    end 
 
endmodule