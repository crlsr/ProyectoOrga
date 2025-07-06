.globl clear_display
clear_display:
    li $t0, 0x10010000  # Base address
    li $t1, 0x000000FF  # Black color
    li $t2, 0           # Counter
    li $t3, 16
    mul $t3, $t3, 32       # Total units (16 width * 32 height)
    
clear_loop:
    sw $t1, 0($t0)      # Store black
    addi $t0, $t0, 4    # Next address
    addi $t2, $t2, 1    # Increment counter
    blt $t2, $t3, clear_loop
    jr $ra