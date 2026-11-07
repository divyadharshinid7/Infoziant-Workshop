`timescale 1ns/1ps
module alu_tb;
    parameter WIDTH = 32;
    localparam SHW = $clog2(WIDTH);

    // op encoding (must match alu.v)
    localparam ADD=4'd0, SUB=4'd1, AND_=4'd2, OR_=4'd3,
               XOR_=4'd4, SLT=4'd5, SLL=4'd6, SRL=4'd7;

    reg  [WIDTH-1:0] a, b;
    reg  [3:0]       op;
    wire [WIDTH-1:0] result;
    wire             zero, negative, carry, overflow;

    integer pass_cnt = 0, fail_cnt = 0, i;

    alu #(.WIDTH(WIDTH)) dut (
        .a(a), .b(b), .op(op), .result(result),
        .zero(zero), .negative(negative), .carry(carry), .overflow(overflow));

    // ---------- reference model (independent of the DUT's coding style) ----------
    reg [WIDTH-1:0] exp_res;
    reg             exp_zero, exp_neg, exp_carry, exp_ovf;

    task ref_model(input [WIDTH-1:0] ra, rb, input [3:0] rop);
        reg [WIDTH:0] wide;
        begin
            exp_carry = 1'b0; exp_ovf = 1'b0; exp_res = {WIDTH{1'b0}};
            case (rop)
                ADD: begin
                    wide = {1'b0, ra} + {1'b0, rb};
                    exp_res = wide[WIDTH-1:0]; exp_carry = wide[WIDTH];
                    exp_ovf = (ra[WIDTH-1] == rb[WIDTH-1]) && (exp_res[WIDTH-1] != ra[WIDTH-1]);
                end
                SUB: begin
                    wide = {1'b0, ra} + {1'b0, ~rb} + 1'b1;
                    exp_res = wide[WIDTH-1:0]; exp_carry = wide[WIDTH];   // carry = not-borrow
                    exp_ovf = (ra[WIDTH-1] != rb[WIDTH-1]) && (exp_res[WIDTH-1] != ra[WIDTH-1]);
                end
                AND_: exp_res = ra & rb;
                OR_:  exp_res = ra | rb;
                XOR_: exp_res = ra ^ rb;
                SLT:  exp_res = ($signed(ra) < $signed(rb)) ? 1 : 0;
                SLL:  exp_res = ra << rb[SHW-1:0];
                SRL:  exp_res = ra >> rb[SHW-1:0];
                default: exp_res = {WIDTH{1'b0}};
            endcase
            exp_zero = (exp_res == {WIDTH{1'b0}});
            exp_neg  = exp_res[WIDTH-1];
        end
    endtask

    // ---------- self-checking task ----------
    task check(input [WIDTH-1:0] ta, tb_, input [3:0] top);
        begin
            a = ta; b = tb_; op = top;
            ref_model(ta, tb_, top);
            #1;
            if (result !== exp_res || zero !== exp_zero || negative !== exp_neg ||
                carry !== exp_carry || overflow !== exp_ovf) begin
                $display("FAIL t=%0t op=%0d a=%h b=%h | got res=%h z=%b n=%b c=%b v=%b | exp res=%h z=%b n=%b c=%b v=%b",
                    $time, top, ta, tb_, result, zero, negative, carry, overflow,
                    exp_res, exp_zero, exp_neg, exp_carry, exp_ovf);
                fail_cnt = fail_cnt + 1;
            end else
                pass_cnt = pass_cnt + 1;
        end
    endtask

    localparam MAXP = {1'b0, {(WIDTH-1){1'b1}}};   // 0x7FFF...
    localparam MINN = {1'b1, {(WIDTH-1){1'b0}}};   // 0x8000...
    localparam ONES = {WIDTH{1'b1}};

    initial begin
        // ---- directed: ADD ----
        check(0, 0, ADD);          check(5, 3, ADD);
        check(ONES, 1, ADD);       check(MAXP, 1, ADD);
        check(MINN, MINN, ADD);    check(ONES, ONES, ADD);
        // ---- directed: SUB ----
        check(5, 5, SUB);          check(3, 5, SUB);
        check(MINN, 1, SUB);       check(0, 1, SUB);
        check(MAXP, ONES, SUB);    check(0, MINN, SUB);
        // ---- directed: logic ----
        check(ONES, 0, AND_);      check(32'hAAAAAAAA, 32'h55555555, OR_);
        check(32'hAAAAAAAA, 32'h55555555, XOR_);  check(ONES, ONES, XOR_);
        // ---- directed: SLT (signed) ----
        check(ONES, 1, SLT);       check(1, ONES, SLT);
        check(5, 5, SLT);          check(MINN, MAXP, SLT);
        // ---- directed: shifts ----
        check(32'h1, 0, SLL);      check(32'h1, 31, SLL);
        check(ONES, 1, SRL);       check(MINN, 31, SRL);
        check(32'h1, 32, SLL);     // amount wraps via low 5 bits
        // ---- random ----
        for (i = 0; i < 500; i = i + 1)
            check($urandom, $urandom, $urandom % 8);

        $display("--------------------------------------------");
        if (fail_cnt == 0) $display("ALL TESTS PASSED: %0d vectors", pass_cnt);
        else               $display("TESTS FAILED: %0d of %0d", fail_cnt, pass_cnt + fail_cnt);
        $display("--------------------------------------------");
        $finish;
    end

    initial begin $dumpfile("day1/waves/alu.vcd"); $dumpvars(0, alu_tb); end
endmodule