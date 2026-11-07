addi x10, x0, 128
addi x11, x0, 12
sw   x11, 0(x10)
addi x11, x0, 7
sw   x11, 4(x10)
addi x11, x0, 44
sw   x11, 8(x10)
addi x11, x0, 3
sw   x11, 12(x10)
addi x11, x0, 99
sw   x11, 16(x10)
addi x11, x0, 5
sw   x11, 20(x10)
addi x11, x0, 21
sw   x11, 24(x10)
addi x11, x0, 9
sw   x11, 28(x10)
lw   x12, 0(x10)
addi x13, x10, 4
addi x14, x0, 7
loop:
lw   x15, 0(x13)
bge  x12, x15, skip
addi x12, x15, 0
skip:
addi x13, x13, 4
addi x14, x14, -1
bne  x14, x0, loop
ecall
