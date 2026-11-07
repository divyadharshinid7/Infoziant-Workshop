`timescale 1ns/1ps
module hazard_tb;
    reg clk=0,reset=0;
    wire data_before_h,data_after_h,load_before_h,load_after_h,branch_before_h,branch_after_h;
    wire [31:0] unused_pc[0:5], unused_cycles[0:5], unused_retired[0:5], unused_stalls[0:5], unused_flushes[0:5];
    integer cycles=0,errors=0;

    rv32_pipeline_mutation #(.OMIT_FORWARDING(1)) data_before(
        clk,reset,data_before_h,unused_pc[0],unused_cycles[0],unused_retired[0],unused_stalls[0],unused_flushes[0]);
    rv32_pipeline data_after(
        clk,reset,data_after_h,unused_pc[1],unused_cycles[1],unused_retired[1],unused_stalls[1],unused_flushes[1]);
    rv32_pipeline_mutation #(.OMIT_LOAD_STALL(1)) load_before(
        clk,reset,load_before_h,unused_pc[2],unused_cycles[2],unused_retired[2],unused_stalls[2],unused_flushes[2]);
    rv32_pipeline load_after(
        clk,reset,load_after_h,unused_pc[3],unused_cycles[3],unused_retired[3],unused_stalls[3],unused_flushes[3]);
    rv32_pipeline_mutation #(.OMIT_FLUSH(1)) branch_before(
        clk,reset,branch_before_h,unused_pc[4],unused_cycles[4],unused_retired[4],unused_stalls[4],unused_flushes[4]);
    rv32_pipeline branch_after(
        clk,reset,branch_after_h,unused_pc[5],unused_cycles[5],unused_retired[5],unused_stalls[5],unused_flushes[5]);
    always #5 clk=~clk;

    initial begin
        $dumpfile("day4/waves/hazards.vcd"); $dumpvars(0,hazard_tb);
        $readmemh("day4/programs/hazard_data.hex",data_before.imem);
        $readmemh("day4/programs/hazard_data.hex",data_after.imem);
        $readmemh("day4/programs/hazard_load.hex",load_before.imem);
        $readmemh("day4/programs/hazard_load.hex",load_after.imem);
        $readmemh("day4/programs/hazard_branch.hex",branch_before.imem);
        $readmemh("day4/programs/hazard_branch.hex",branch_after.imem);
        @(negedge clk); reset=1;
        repeat(2) @(posedge clk);
        @(negedge clk); reset=0;
        load_before.dmem[32]=42;
        load_after.dmem[32]=42;
        while((!data_before_h || !data_after_h || !load_before_h ||
               !load_after_h || !branch_before_h || !branch_after_h) && cycles<100) begin
            @(posedge clk); cycles=cycles+1;
        end
        #1;
        if(data_after.registers[3]!==12 || data_before.registers[3]===12) errors=errors+1;
        if(load_after.registers[3]!==43 || load_before.registers[3]===43 ||
           load_before.stall_cycles!==0 || load_after.stall_cycles!==1) errors=errors+1;
        if(branch_after.registers[5]!==0 || branch_after.registers[6]!==1 ||
           branch_before.registers[5]!==7 || branch_before.flush_cycles!==0 ||
           branch_after.flush_cycles==0) errors=errors+1;
        if(errors==0)
            $display("PASS hazard before/after; data=%0d/%0d load=%0d/%0d branch wrong-path=%0d",
                data_before.registers[3],data_after.registers[3],
                load_before.registers[3],load_after.registers[3],branch_before.registers[5]);
        else
            $display("FAIL hazard tests; data=%0d/%0d load=%0d/%0d branch=%0d/%0d",
                data_before.registers[3],data_after.registers[3],
                load_before.registers[3],load_after.registers[3],
                branch_before.registers[5],branch_after.registers[5]);
        $finish;
    end
endmodule
