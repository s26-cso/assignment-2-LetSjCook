.section .data
fname:  .asciz "input.txt"     # file name to open
yesmsg: .asciz "Yes\n"         # message if palindrome
nomsg:  .asciz "No\n"          # message if not palindrome

.section .bss
buf: .skip 1024                # buffer to store file contents

.section .text
.globl _start

_start:

    li a0, -100                # special value for current directory
    la a1, fname               # pointer to file name
    li a2, 0                   # open mode (read only)
    li a3, 0                   # flags (unused here)
    li a7, 56                  # syscall: openat
    ecall                      # make syscall
    mv s0, a0                  # save file descriptor

    bltz s0, print_no          # if fd < 0, file open failed

    mv a0, s0                  # file descriptor
    la a1, buf                 # buffer address
    li a2, 1024                # max bytes to read
    li a7, 63                  # syscall: read
    ecall                      # read file
    mv s1, a0                  # number of bytes read

    mv a0, s0                  # file descriptor
    li a7, 57                  # syscall: close
    ecall                      # close file

    li t0, 0                   # left index = 0
    addi t1, s1, -1            # right index = size - 1

check_loop:
    bge t0, t1, print_yes      # if pointers cross, it's palindrome

    la t2, buf                 # base address of buffer
    add t3, t2, t0             # address of left char
    lb t4, 0(t3)               # load left character

    la t2, buf                 # base address again
    add t3, t2, t1             # address of right char
    lb t5, 0(t3)               # load right character

    bne t4, t5, print_no       # if mismatch, not palindrome

    addi t0, t0, 1             # move left pointer right
    addi t1, t1, -1            # move right pointer left
    j check_loop               # repeat loop

print_yes:
    li a0, 1                   # file descriptor (stdout)
    la a1, yesmsg              # message address
    li a2, 4                   # length of "Yes\n"
    li a7, 64                  # syscall: write
    ecall                      # print Yes
    j exit                     # go to exit

print_no:
    li a0, 1                   # file descriptor (stdout)
    la a1, nomsg               # message address
    li a2, 3                   # length of "No\n"
    li a7, 64                  # syscall: write
    ecall                      # print No

exit:
    li a0, 0                   # exit code
    li a7, 93                  # syscall: exit
    ecall                      # terminate program
    
