addi x1, x0, 0
addi x2, x0, 0
addi x3, x0, 1
addi x4, x0, 10
loop:
sw   x2, 0(x1)
add  x5, x2, x3
addi x2, x3, 0
addi x3, x5, 0
addi x1, x1, 4
addi x4, x4, -1
bne  x4, x0, loop
ecall
