addi x1, x0, 10
addi x2, x0, 0
addi x3, x0, 1
loop:
add  x2, x2, x3
addi x3, x3, 1
bge  x1, x3, loop
ecall
