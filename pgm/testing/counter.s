.globl _start

_start:

addi x11, x11, 4
LOOP:

addi x10, x10, 1
bne x10, x11, LOOP

INC:
addi x12, x12, 1
andi x12, x12, 255
sw x12, 0(x0)
sub x10, x10, x10
beq x10, x0, LOOP
