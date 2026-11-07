module adder_sub (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire mode,
    output wire [7:0] result,
    output wire carry_out,
    output wire overflow
);
    wire [7:0] bx;
    wire [8:0] carry;
    assign bx = b ^ {8{mode}};
    assign carry[0] = mode;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_slice
            full_adder fa (
                .a(a[i]), .b(bx[i]), .carry_in(carry[i]),
                .sum(result[i]), .carry_out(carry[i+1])
            );
        end
    endgenerate
    assign carry_out = carry[8];
    assign overflow = ~(a[7] ^ bx[7]) & (result[7] ^ a[7]);
endmodule
