module full_adder (
    input wire a,
    input wire b,
    input wire carry_in,
    output wire sum,
    output wire carry_out
);
    assign {carry_out, sum} = a + b + carry_in;
endmodule
