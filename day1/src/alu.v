// alu.v - Parameterized ALU (Activity 1.1)
// op: 0=ADD 1=SUB 2=AND 3=OR 4=XOR 5=SLT 6=SLL 7=SRL
// carry on SUB = carry-out of a + ~b + 1 (i.e. NOT borrow)
module alu #(parameter WIDTH = 32) (
    input  [WIDTH-1:0]     a, b,
    input  [3:0]           op,
    output reg [WIDTH-1:0] result,
    output                 zero, negative,
    output reg             carry, overflow
);
    localparam ADD=4'd0, SUB=4'd1, AND_=4'd2, OR_=4'd3,
               XOR_=4'd4, SLT=4'd5, SLL=4'd6, SRL=4'd7;
    localparam SHW = $clog2(WIDTH);

    // shared adder for ADD, SUB, SLT
    wire             sub   = (op == SUB) | (op == SLT);
    wire [WIDTH-1:0] b_in  = sub ? ~b : b;
    wire [WIDTH:0]   sum   = {1'b0, a} + {1'b0, b_in} + sub;
    wire             add_ovf = ~(a[WIDTH-1] ^ b_in[WIDTH-1]) &
                                (sum[WIDTH-1] ^ a[WIDTH-1]);

    always @(*) begin
        result   = {WIDTH{1'b0}};
        carry    = 1'b0;
        overflow = 1'b0;
        case (op)
            ADD, SUB: begin
                result   = sum[WIDTH-1:0];
                carry    = sum[WIDTH];
                overflow = add_ovf;
            end
            AND_: result = a & b;
            OR_:  result = a | b;
            XOR_: result = a ^ b;
            SLT:  result = {{(WIDTH-1){1'b0}}, (sum[WIDTH-1] ^ add_ovf)};
            SLL:  result = a << b[SHW-1:0];
            SRL:  result = a >> b[SHW-1:0];
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero     = ~|result;
    assign negative = result[WIDTH-1];
endmodule