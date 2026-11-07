lui   x1, 0x12345
addi  x2, x0, -8
andi  x3, x2, 15
ori   x4, x0, 16
xori  x5, x4, 3
slti  x6, x2, 0
slli  x7, x4, 2
srli  x8, x7, 1
srai  x22, x2, 1
sra   x23, x2, x6
add   x9, x7, x8
sub   x10, x9, x8
and   x11, x4, x8
or    x12, x4, x8
xor   x13, x7, x4
slt   x14, x2, x0
sll   x15, x4, x0
srl   x16, x7, x0
sw    x7, 0(x0)
beq   x0, x0, branch_ok
addi  x21, x0, 99
branch_ok:
bne   x2, x0, not_equal
addi  x21, x0, 98
not_equal:
bge   x0, x2, signed_ok
addi  x21, x0, 97
signed_ok:
blt   x2, x0, jal_start
addi  x21, x0, 96
jal_start:
jal   x17, jal_target
addi  x21, x0, 95
jal_target:
addi  x18, x0, 1
addi  x19, x0, 136
jalr  x20, 0(x19)
addi  x21, x0, 94
addi  x21, x0, 93
jalr_target:
ecall
