.section .data
fname:  .asciz "input.txt"
yesmsg: .asciz "Yes\n"
nomsg:  .asciz "No\n"

.section .bss
buf: .skip 1024

.section .text
.globl main
main:

    li a0, -100
    la a1, fname
    li a2, 0
    li a3, 0
    li a7, 56
    ecall
    mv s0, a0

    bltz s0, print_no

    mv a0, s0
    la a1, buf
    li a2, 1024
    li a7, 63
    ecall
    mv s1, a0

    mv a0, s0
    li a7, 57
    ecall

    beqz s1, print_yes

    li t0, 0
    addi t1, s1, -1

    la t2, buf
    add t3, t2, t1
    lb t4, 0(t3)
    li t5, '\n'
    bne t4, t5, check_cr
    addi t1, t1, -1

check_cr:
    la t2, buf
    add t3, t2, t1
    lb t4, 0(t3)
    li t5, '\r'
    bne t4, t5, check_loop
    addi t1, t1, -1

check_loop:
    bge t0, t1, print_yes

    la t2, buf
    add t3, t2, t0
    lb t4, 0(t3)

    la t2, buf
    add t3, t2, t1
    lb t5, 0(t3)

    bne t4, t5, print_no

    addi t0, t0, 1
    addi t1, t1, -1
    j check_loop

print_yes:
    li a0, 1
    la a1, yesmsg
    li a2, 4
    li a7, 64
    ecall
    j exit

print_no:
    li a0, 1
    la a1, nomsg
    li a2, 3
    li a7, 64
    ecall

exit:
    li a0, 0
    li a7, 93
    ecall
