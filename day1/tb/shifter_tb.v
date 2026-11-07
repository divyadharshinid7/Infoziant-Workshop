`timescale 1ns/1ps
module shifter_tb;
    reg [31:0] data_in;
    reg [4:0] amount;
    reg [1:0] mode;
    wire [31:0] data_out;
    reg [31:0] expected;
    integer i, m, errors=0;
    barrel_shifter dut(data_in,amount,mode,data_out);
    initial begin
        $dumpfile("day1/waves/shifter.vcd"); $dumpvars(0,shifter_tb);
        data_in=32'h81234567;
        for(m=0;m<3;m=m+1)
            for(i=0;i<32;i=i+1) begin
                mode=m; amount=i; #1;
                case(m)
                    0: expected=data_in<<i;
                    1: expected=data_in>>i;
                    2: expected=$signed(data_in)>>>i;
                endcase
                if(data_out!==expected) begin
                    $display("FAIL shifter mode=%0d amount=%0d got=%h expected=%h",m,i,data_out,expected);
                    errors=errors+1;
                end
            end
        if(errors==0) $display("PASS shifter 96 checks"); else $display("FAIL shifter errors=%0d",errors);
        $finish;
    end
endmodule
