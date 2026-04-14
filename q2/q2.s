.section .data
fmt: .string "%ld "        # format string for printing numbers

.section .text
.globl main

main:
    addi sp, sp, -320      # allocate stack space
    sd ra, 312(sp)         # save return address
    sd s0, 304(sp)         # save s0
    sd s1, 296(sp)         # save s1
    sd s2, 288(sp)         # save s2
    sd s3, 280(sp)         # save s3

    mv s0, a0              # s0 = argc
    mv s1, a1              # s1 = argv
    addi s0, s0, -1        # n = argc - 1
    mv s2, s0              # store n in s2

    li t0, 0               # i = 0
read:
    bge t0, s2, init       # if i >= n, go to init

    addi t1, t0, 1         # t1 = i + 1 (skip program name)
    slli t1, t1, 3         # multiply by 8 (64-bit pointer)
    add t2, s1, t1         # address of argv[i+1]
    ld a0, 0(t2)           # load string argument
    call atoi              # convert string to integer

    slli t3, t0, 3         # offset = i * 8
    add t4, sp, t3         # address for A[i]
    sd a0, 0(t4)           # store value in array

    addi t0, t0, 1         # i++
    j read                 # repeat loop

init:
    li t0, 0               # i = 0
init_loop:
    bge t0, s2, start      # if i >= n, go to main logic

    slli t1, t0, 3         # offset = i * 8
    add t2, sp, t1         # base address
    addi t2, t2, 80        # move to result array
    li t3, -1              # default value = -1
    sd t3, 0(t2)           # res[i] = -1

    addi t0, t0, 1         # i++
    j init_loop            # repeat

start:
    li s3, -1              # stack top = -1 (empty)
    addi t0, s2, -1        # start from last index (n-1)

outer:
    blt t0, zero, print    # if i < 0, go to print

inner:
    blt s3, zero, assign   # if stack empty, skip popping

    slli t1, s3, 3         # offset = top * 8
    add t2, sp, t1         
    addi t2, t2, 160       # stack base location
    ld t3, 0(t2)           # load index at stack top

    slli t4, t3, 3         
    add t5, sp, t4         
    ld t5, 0(t5)           # value A[stack top]

    slli t4, t0, 3         
    add t6, sp, t4         
    ld t6, 0(t6)           # current value A[i]

    ble t5, t6, pop        # if stack value <= current, pop
    j assign               # otherwise assign result

pop:
    addi s3, s3, -1        # decrease stack top
    j inner                # continue popping

assign:
    blt s3, zero, push     # if stack empty, skip assign

    slli t1, s3, 3         
    add t2, sp, t1         
    addi t2, t2, 160       
    ld t3, 0(t2)           # get index from stack

    slli t4, t0, 3         
    add t5, sp, t4         
    addi t5, t5, 80        
    sd t3, 0(t5)           # store index in result[i]

push:
    addi s3, s3, 1         # increment stack top

    slli t1, s3, 3         
    add t2, sp, t1         
    addi t2, t2, 160       
    sd t0, 0(t2)           # push current index

    addi t0, t0, -1        # i--
    j outer                # repeat outer loop

print:
    li t0, 0               # i = 0
loop:
    bge t0, s2, exit       # if i >= n, exit

    slli t1, t0, 3         
    add t2, sp, t1         
    addi t2, t2, 80        
    ld a1, 0(t2)           # load result[i]

    la a0, fmt             # load format string
    call printf            # print value

    addi t0, t0, 1         # i++
    j loop                 # repeat

exit:
    ld ra, 312(sp)         # restore return address
    ld s0, 304(sp)         # restore s0
    ld s1, 296(sp)         # restore s1
    ld s2, 288(sp)         # restore s2
    ld s3, 280(sp)         # restore s3

    addi sp, sp, 320       # deallocate stack
    li a0, 0               # return 0
    ret                    # return from main
