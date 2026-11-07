`timescale 1ns/1ps
module pipeline_tb;
    reg clk=0, reset=0;
    wire single_halted, pipeline_halted;
    wire [31:0] single_pc,single_instruction,single_alu,single_wb;
    wire [31:0] pipe_pc,total_cycles,instructions_retired,stall_cycles,flush_cycles;
    integer errors=0, cycles=0, single_cycles=0, single_instructions=0, i;
    rv32_single single_cpu(clk,reset,single_halted,single_pc,single_instruction,single_alu,single_wb);
    rv32_pipeline pipeline_cpu(clk,reset,pipeline_halted,pipe_pc,total_cycles,
        instructions_retired,stall_cycles,flush_cycles);
    always #5 clk=~clk;
    always @(posedge clk)
        if(!reset && !single_halted) begin
            single_cycles=single_cycles+1;
            if(single_instruction!=32'h00000073) single_instructions=single_instructions+1;
        end

    task run_both;
        begin
            @(negedge clk); reset=1; cycles=0; single_cycles=0; single_instructions=0;
            repeat(2) @(posedge clk);
            @(negedge clk); reset=0;
            while((!single_halted || !pipeline_halted) && cycles<20000) begin
                @(posedge clk); cycles=cycles+1;
            end
            #1;
            if(!single_halted || !pipeline_halted) begin
                $display("FAIL timeout single_pc=%h pipe_pc=%h",single_pc,pipe_pc);
                errors=errors+1;
            end
        end
    endtask

    task report_counts(input [8*24-1:0] name);
        begin
            $display("%0s | single cycles=%0d instr=%0d | pipe cycles=%0d instr=%0d stalls=%0d flushes=%0d",
                name,single_cycles,single_instructions,total_cycles,instructions_retired,stall_cycles,flush_cycles);
        end
    endtask

    initial begin
        $dumpfile("day4/waves/pipeline.vcd"); $dumpvars(0,pipeline_tb);

        $readmemh("day3/programs/program1.hex",single_cpu.imem);
        $readmemh("day3/programs/program1.hex",pipeline_cpu.imem);
        run_both; report_counts("sum 1..10");
        if(single_cpu.registers[2]!==55 || pipeline_cpu.registers[2]!==55) begin
            $display("FAIL pipeline sum results"); errors=errors+1;
        end else $display("PASS pipeline program 1");

        $readmemh("day3/programs/program2.hex",single_cpu.imem);
        $readmemh("day3/programs/program2.hex",pipeline_cpu.imem);
        run_both; report_counts("Fibonacci");
        for(i=0;i<10;i=i+1)
            if(single_cpu.dmem[i]!==pipeline_cpu.dmem[i]) errors=errors+1;
        if(pipeline_cpu.dmem[9]!==34) begin $display("FAIL pipeline Fibonacci"); errors=errors+1; end
        else $display("PASS pipeline program 2");

        $readmemh("day3/programs/program3.hex",single_cpu.imem);
        $readmemh("day3/programs/program3.hex",pipeline_cpu.imem);
        run_both; report_counts("array maximum");
        if(single_cpu.registers[12]!==99 || pipeline_cpu.registers[12]!==99) begin
            $display("FAIL pipeline maximum"); errors=errors+1;
        end else $display("PASS pipeline program 3");

        $readmemh("day4/programs/program4.hex",single_cpu.imem);
        $readmemh("day4/programs/program4.hex",pipeline_cpu.imem);
        run_both; report_counts("bubble sort");
        for(i=0;i<8;i=i+1)
            if(single_cpu.dmem[32+i]!==pipeline_cpu.dmem[32+i] ||
               pipeline_cpu.dmem[32+i]!==((i<4)?i+1:i+2)) begin
                $display("sort mismatch index=%0d single=%0d pipe=%0d expected=%0d",
                    i,single_cpu.dmem[32+i],pipeline_cpu.dmem[32+i],((i<4)?i+1:i+2));
                errors=errors+1;
            end
        if(errors==0) $display("PASS pipeline program 4 bubble sort");
        else $display("FAIL pipeline program 4 errors=%0d",errors);

        $readmemh("day4/programs/program5.hex",single_cpu.imem);
        $readmemh("day4/programs/program5.hex",pipeline_cpu.imem);
        run_both; report_counts("GCD");
        if(single_cpu.registers[1]!==6 || pipeline_cpu.registers[1]!==6 ||
           single_cpu.registers[2]!==6 || pipeline_cpu.registers[2]!==6) begin
            $display("FAIL pipeline GCD"); errors=errors+1;
        end else $display("PASS pipeline program 5");

        $readmemh("day4/programs/program6.hex",single_cpu.imem);
        $readmemh("day4/programs/program6.hex",pipeline_cpu.imem);
        run_both; report_counts("shift-add multiply");
        if(single_cpu.registers[3]!==143 || pipeline_cpu.registers[3]!==143) begin
            $display("FAIL pipeline multiply"); errors=errors+1;
        end else $display("PASS pipeline program 6");

        $readmemh("day3/programs/coverage.hex",single_cpu.imem);
        $readmemh("day3/programs/coverage.hex",pipeline_cpu.imem);
        run_both; report_counts("ISA coverage");
        if(single_cpu.registers[1]!==32'h12345000 ||
           pipeline_cpu.registers[1]!==32'h12345000 ||
           single_cpu.registers[17]!==112 || pipeline_cpu.registers[17]!==112 ||
           single_cpu.registers[20]!==128 || pipeline_cpu.registers[20]!==128 ||
           single_cpu.registers[22]!==32'hfffffffc || pipeline_cpu.registers[22]!==32'hfffffffc ||
           single_cpu.registers[23]!==32'hfffffffc || pipeline_cpu.registers[23]!==32'hfffffffc ||
           single_cpu.registers[21]!==0 || pipeline_cpu.registers[21]!==0 ||
           pipeline_cpu.dmem[0]!==64) begin
            $display("FAIL pipe coverage x22=%h x23=%h x17=%h x19=%h x20=%h x21=%h mem0=%h",
                pipeline_cpu.registers[22],pipeline_cpu.registers[23],pipeline_cpu.registers[17],
                pipeline_cpu.registers[19],pipeline_cpu.registers[20],pipeline_cpu.registers[21],
                pipeline_cpu.dmem[0]);
            errors=errors+1;
        end else $display("PASS pipeline instruction/branch/JAL/JALR coverage");

        if(errors==0) $display("ALL PIPELINE PROGRAMS PASSED");
        else $display("PIPELINE FAILURES: %0d",errors);
        $finish;
    end
endmodule
