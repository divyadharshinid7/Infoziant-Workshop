addi x10, x0, 128
addi x11, x0, 8
sw   x11, 0(x10)
addi x11, x0, 3
sw   x11, 4(x10)
addi x11, x0, 7
sw   x11, 8(x10)
addi x11, x0, 1
sw   x11, 12(x10)
addi x11, x0, 9
sw   x11, 16(x10)
addi x11, x0, 2
sw   x11, 20(x10)
addi x11, x0, 6
sw   x11, 24(x10)
addi x11, x0, 4
sw   x11, 28(x10)
addi x12, x0, 0
addi x18, x0, 7
outer:
sub  x13, x18, x12
addi x14, x10, 0
inner:
lw   x15, 0(x14)
lw   x16, 4(x14)
bge  x16, x15, no_swap
sw   x16, 0(x14)
sw   x15, 4(x14)
no_swap:
addi x14, x14, 4
addi x13, x13, -1
bne  x13, x0, inner
addi x12, x12, 1
blt  x12, x18, outer
ecall
