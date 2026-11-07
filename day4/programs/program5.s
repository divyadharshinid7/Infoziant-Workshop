addi x1, x0, 48
addi x2, x0, 18
loop:
beq  x1, x2, done
blt  x1, x2, subtract_a
sub  x1, x1, x2
jal  x0, loop
subtract_a:
sub  x2, x2, x1
jal  x0, loop
done:
ecall
