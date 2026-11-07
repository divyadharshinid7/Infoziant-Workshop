`timescale 1ns/1ps
module memory_watchdog_tb;
    reg clk=0,write_enable=0,kick=0,enable=0,reset=0;
    reg [3:0] address=0;
    reg [7:0] data_in=0;
    reg [15:0] timeout_value=0;
    wire [7:0] ram_data,rom_data;
    wire reset_pulse;
    wire [15:0] count;
    integer errors=0;
    sync_ram16x8 ram(clk,write_enable,address,data_in,ram_data);
    sync_rom16x8 #(.INIT_FILE("day2/src/rom.hex")) rom(clk,address,rom_data);
    watchdog_timer #(.WIDTH(16)) wd(clk,reset,kick,enable,timeout_value,reset_pulse,count);
    always #5 clk=~clk;
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day2/waves/memory_watchdog.vcd"); $dumpvars(0,memory_watchdog_tb);
        address=3; tick; if(rom_data!==8'h33) errors=errors+1;
        write_enable=1; data_in=8'ha5; tick; write_enable=0; tick;
        if(ram_data!==8'ha5) errors=errors+1;
        reset=1; timeout_value=4; tick; reset=0; enable=1;
        repeat(2) tick;
        kick=1; tick; kick=0;
        repeat(3) tick;
        if(reset_pulse) errors=errors+1;
        tick;
        if(!reset_pulse) errors=errors+1;
        if(errors==0) $display("PASS RAM/ROM/watchdog kick and timeout");
        else $display("FAIL memory/watchdog errors=%0d",errors);
        $finish;
    end
endmodule
