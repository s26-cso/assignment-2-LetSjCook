.text

.global make_node
make_node:
    addi sp, sp, -16        # make space on stack
    sd   a0, 0(sp)          # save input value
    sd   ra, 8(sp)          # save return address

    li   a0, 24             # allocate 24 bytes for node
    call malloc             # call malloc

    ld   t0, 0(sp)          # load original value
    sw   t0,  0(a0)         # store value in node
    sd   x0,  8(a0)         # left child = NULL
    sd   x0, 16(a0)         # right child = NULL

    ld   ra, 8(sp)          # restore return address
    addi sp, sp, 16         # free stack space
    ret                     # return pointer to node


.global insert
insert:
    addi sp, sp, -32        # create stack frame
    sd   ra, 24(sp)         # save return address
    sd   a1, 16(sp)         # save value to insert
    sd   a0,  8(sp)         # save root pointer

    bne  a0, x0, insert_nonempty   # if root != NULL, go to insert logic

    mv   a0, a1             # move value into a0
    jal  ra, make_node      # create new node
    j    insert_done        # jump to end

insert_nonempty:
    lw   t0, 0(a0)          # load current node value
    blt  t0, a1, insert_right  # if node < value, go right
    beq  t0, a1, insert_done   # if equal, do nothing

insert_left:
    ld   a0, 8(a0)          # move to left child
    ld   a1, 16(sp)         # reload value
    jal  ra, insert         # recursive insert
    ld   t1,  8(sp)         # load original node
    sd   a0,  8(t1)         # update left child pointer
    mv   a0, t1             # return original node
    j    insert_done        # jump to end

insert_right:
    ld   a0, 16(a0)         # move to right child
    ld   a1, 16(sp)         # reload value
    jal  ra, insert         # recursive insert
    ld   t1,  8(sp)         # load original node
    sd   a0, 16(t1)         # update right child pointer
    mv   a0, t1             # return original node

insert_done:
    ld   ra, 24(sp)         # restore return address
    addi sp, sp, 32         # free stack frame
    ret                     # return root


.global get
get:
    beq  a0, x0, get_null   # if node is NULL, return 0

    lw   t0, 0(a0)          # load node value
    blt  t0, a1, get_right  # if node < key, go right
    bgt  t0, a1, get_left   # if node > key, go left

get_found:
    ret                     # value found, return node pointer

get_right:
    ld   a0, 16(a0)         # move to right child
    j    get                # repeat search

get_left:
    ld   a0, 8(a0)          # move to left child
    j    get                # repeat search

get_null:
    li   a0, 0              # return NULL
    ret


.global getAtMost
getAtMost:
    beq  a1, x0, gam_null   # if node is NULL, return -1

    lw   t0, 0(a1)          # load node value
    bgt  t0, a0, gam_go_left  # if node > key, go left
    beq  t0, a0, gam_exact    # if equal, return value

    ld   t2, 16(a1)         # get right child

    addi sp, sp, -32        # create stack frame
    sd   ra, 24(sp)         # save return address
    sd   a0, 16(sp)         # save key
    sd   t0,  8(sp)         # save current value

    mv   a1, t2             # move to right subtree
    jal  ra, getAtMost      # recursive call

    ld   t0,  8(sp)         # restore current value
    ld   ra, 24(sp)         # restore return address
    addi sp, sp, 32         # free stack

    li   t3, -1             # check if result was -1
    bne  a0, t3, gam_done   # if not -1, keep result

    mv   a0, t0             # else use current node value
gam_done:
    ret                     # return result

gam_go_left:
    ld   a1, 8(a1)          # move to left child
    j    getAtMost          # continue search

gam_exact:
    mv   a0, t0             # return exact match
    ret

gam_null:
    li   a0, -1             # return -1 if not found
    ret
