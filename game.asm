
.include "azul.asm"

.data
	 
.text
.globl main
main:
    jal init
    j end

end:
    j end
    
init:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal clear_display
    jal draw_horizontal_line

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra