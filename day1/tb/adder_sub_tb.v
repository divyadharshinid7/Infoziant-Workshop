`timescale 1ns/1ps
module adder_sub_tb;
    reg [7:0] a,b;
    reg mode;
    wire [7:0] result;
    wire carry_out,overflow;
    reg [7:0] expected;
    reg [8:0] wide;
    reg expected_overflow;
    reg expected_carry;
    integer i,errors=0;
    adder_sub dut(a,b,mode,result,carry_out,overflow);
    initial begin
        $dumpfile("day1/waves/adder_sub.vcd"); $dumpvars(0,adder_sub_tb);
        for(i=0;i<4000;i=i+1) begin
            a=$random; b=$random; mode=i[0]; #1;
            if(mode) begin
                wide={1'b0,a}+{1'b0,~b}+1'b1;
                expected=wide[7:0];
                expected_carry=wide[8];
                expected_overflow=(a[7]!=b[7])&&(expected[7]!=a[7]);
            end else begin
                wide={1'b0,a}+{1'b0,b};
                expected=wide[7:0];
                expected_carry=wide[8];
                expected_overflow=(a[7]==b[7])&&(expected[7]!=a[7]);
            end
            if(result!==expected || carry_out!==expected_carry ||
               overflow!==expected_overflow) errors=errors+1;
        end
        if(errors==0) $display("PASS adder_sub 4000 random vectors");
        else $display("FAIL adder_sub errors=%0d",errors);
        $finish;
    end
endmodule
