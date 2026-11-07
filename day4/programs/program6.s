addi x1, x0, 13
addi x2, x0, 11
addi x3, x0, 0
loop:
beq  x2, x0, done
andi x5, x2, 1
beq  x5, x0, skip_add
add  x3, x3, x1
skip_add:
slli x1, x1, 1
srli x2, x2, 1
jal  x0, loop
done:
ecall
