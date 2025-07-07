.text

.globl clear_display
clear_display:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0x10010000
    li $t1, 0x0000FF  # azul
    li $t2, 0
    li $t3, 16
    mul $t3, $t3, 32

clear_loop:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    blt $t2, $t3, clear_loop

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


.globl draw_horizontal_line
draw_horizontal_line:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0x10010000
    li $t1, 0x00000000   # negro
    li $t2, 16           # ancho
    li $t3, 16           # fila central
    li $t4, 0

draw_line_loop:
    mul $t5, $t3, $t2
    add $t5, $t5, $t4
    sll $t5, $t5, 2
    add $t5, $t5, $t0

    sw $t1, 0($t5)
    addi $t4, $t4, 1
    blt $t4, $t2, draw_line_loop

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra