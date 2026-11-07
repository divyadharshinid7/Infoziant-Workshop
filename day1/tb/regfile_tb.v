`timescale 1ns/1ps
module regfile_tb;
    reg clk=0, write_enable=0;
    reg [4:0] read_addr1=0, read_addr2=0, write_addr=0;
    reg [31:0] write_data=0;
    wire [31:0] read_data1, read_data2;
    reg [31:0] model [1:31];
    integer i, addr, errors=0;
    reg [31:0] value;
    regfile dut(clk,write_enable,read_addr1,read_addr2,write_addr,write_data,read_data1,read_data2);
    always #5 clk=~clk;
    initial begin
        $dumpfile("day1/waves/regfile.vcd"); $dumpvars(0,regfile_tb);
        for(i=1;i<32;i=i+1) model[i]=0;
        // x0 is immutable and same-cycle reads bypass a pending write.
        write_enable=1; write_addr=0; write_data=32'hdeadbeef; read_addr1=0; #1;
        if(read_data1!==0) errors=errors+1;
        write_addr=5; write_data=32'h12345678; read_addr1=5; read_addr2=5; #1;
        if(read_data1!==write_data || read_data2!==write_data) errors=errors+1;
        @(posedge clk); #1; model[5]=32'h12345678;
        // Back-to-back writes followed by 200 deterministic pseudo-random operations.
        for(i=0;i<202;i=i+1) begin
            addr=(i<2)?i+6:($random & 31);
            value=$random;
            write_enable=1; write_addr=addr; write_data=value;
            read_addr1=addr; read_addr2=$random & 31; #1;
            if(addr!=0 && read_data1!==value) errors=errors+1;
            if(read_addr2==0) begin if(read_data2!==0) errors=errors+1; end
            else if(read_addr2==addr) begin if(read_data2!==value) errors=errors+1; end
            else if(read_data2!==model[read_addr2]) errors=errors+1;
            @(posedge clk); #1;
            if(addr!=0) model[addr]=value;
        end
        if(errors==0) $display("PASS regfile 204 directed/random operations");
        else $display("FAIL regfile errors=%0d",errors);
        $finish;
    end
endmodule
