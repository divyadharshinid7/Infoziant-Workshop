`timescale 1ns/1ps
module cpu_tb;
    reg clk=0, reset=0;
    wire halted;
    wire [31:0] pc,instruction,alu_result,writeback_data;
    integer errors=0, cycles, i;
    rv32_single dut(clk,reset,halted,pc,instruction,alu_result,writeback_data);
    always #5 clk=~clk;

    task start_program;
        begin
            @(negedge clk); reset=1;
            repeat(2) @(posedge clk);
            @(negedge clk); reset=0;
            cycles=0;
            while(!halted && cycles<5000) begin @(posedge clk); cycles=cycles+1; end
            #1;
            if(!halted) begin $display("FAIL CPU timeout pc=%h",pc); errors=errors+1; end
        end
    endtask

    initial begin
        $dumpfile("day3/waves/cpu.vcd"); $dumpvars(0,cpu_tb);
        $readmemh("day3/programs/program1.hex",dut.imem);
        start_program;
        if(dut.registers[2]!==55) begin $display("FAIL sum: x2=%0d",dut.registers[2]); errors=errors+1; end
        else $display("PASS program 1 sum 1..10 = %0d",dut.registers[2]);

        $readmemh("day3/programs/program2.hex",dut.imem);
        start_program;
        if(dut.dmem[0]!==0 || dut.dmem[1]!==1 || dut.dmem[2]!==1 ||
           dut.dmem[3]!==2 || dut.dmem[4]!==3 || dut.dmem[5]!==5 ||
           dut.dmem[6]!==8 || dut.dmem[7]!==13 || dut.dmem[8]!==21 || dut.dmem[9]!==34) begin
            $display("FAIL Fibonacci memory output");
            errors=errors+1;
        end else $display("PASS program 2 Fibonacci words stored");

        $readmemh("day3/programs/program3.hex",dut.imem);
        start_program;
        if(dut.registers[12]!==99) begin $display("FAIL maximum: x12=%0d",dut.registers[12]); errors=errors+1; end
        else $display("PASS program 3 maximum = %0d",dut.registers[12]);

        $readmemh("day3/programs/coverage.hex",dut.imem);
        start_program;
        if(dut.registers[1]!==32'h12345000 || dut.registers[3]!==8 ||
           dut.registers[4]!==16 || dut.registers[5]!==19 || dut.registers[6]!==1 ||
           dut.registers[7]!==64 || dut.registers[8]!==32 || dut.registers[9]!==96 ||
           dut.registers[10]!==64 || dut.registers[11]!==0 || dut.registers[12]!==48 ||
           dut.registers[13]!==80 || dut.registers[14]!==1 || dut.registers[15]!==16 ||
           dut.registers[16]!==64 || dut.registers[22]!==32'hfffffffc ||
           dut.registers[23]!==32'hfffffffc || dut.dmem[0]!==64 || dut.registers[17]!==112 ||
           dut.registers[18]!==1 || dut.registers[20]!==128 || dut.registers[21]!==0) begin
            $display("FAIL coverage x22=%h x23=%h x17=%h x19=%h x20=%h x21=%h",
                dut.registers[22],dut.registers[23],dut.registers[17],dut.registers[19],
                dut.registers[20],dut.registers[21]);
            errors=errors+1;
        end else $display("PASS instruction coverage and signed branch/JAL/JALR checks");

        if(errors==0) $display("ALL CPU PROGRAMS PASSED");
        else $display("CPU FAILURES: %0d",errors);
        $finish;
    end
endmodule
