`timescale 1ns/1ps
module bug_hunt_tb;
    reg clk=0,reset=0;
    wire sign_halted,x0_halted,branch_halted;
    wire [31:0] sign_pc,sign_inst,sign_alu,sign_wb;
    wire [31:0] x0_pc,x0_inst,x0_alu,x0_wb;
    wire [31:0] branch_pc,branch_inst,branch_alu,branch_wb;
    integer cycles,errors=0;
    rv32_single_bad_sign s(clk,reset,sign_halted,sign_pc,sign_inst,sign_alu,sign_wb);
    rv32_single_bad_x0 z(clk,reset,x0_halted,x0_pc,x0_inst,x0_alu,x0_wb);
    rv32_single_bad_branch b(clk,reset,branch_halted,branch_pc,branch_inst,branch_alu,branch_wb);
    always #5 clk=~clk;
    initial begin
        $dumpfile("day3/waves/bug_hunt.vcd"); $dumpvars(0,bug_hunt_tb);
        $readmemh("day3/bugs/signext.hex",s.imem);
        $readmemh("day3/bugs/x0.hex",z.imem);
        $readmemh("day3/bugs/branch.hex",b.imem);
        @(negedge clk); reset=1;
        repeat(2) @(posedge clk);
        @(negedge clk); reset=0;
        cycles=0;
        while((!sign_halted || !x0_halted || !branch_halted) && cycles<40) begin
            @(posedge clk); cycles=cycles+1;
        end
        #1;
        if(sign_halted && s.registers[1]!==32'hfffffff8)
            $display("DETECTED: sign-extension bug (x1=%h)",s.registers[1]);
        else begin $display("MISSED: sign-extension mutation"); errors=errors+1; end
        if(x0_halted && z.registers[1]!==1)
            $display("DETECTED: writable x0 bug (x0=%h, x1=%h)",z.registers[0],z.registers[1]);
        else begin $display("MISSED: writable-x0 mutation"); errors=errors+1; end
        if(!branch_halted)
            $display("DETECTED: branch-target +4 bug (CPU did not reach ecall; PC=%h)",branch_pc);
        else begin $display("MISSED: branch-target mutation"); errors=errors+1; end
        if(errors==0) $display("PASS bug-hunt detected all three injected CPU bugs");
        else $display("FAIL bug-hunt missed %0d mutations",errors);
        $finish;
    end
endmodule
