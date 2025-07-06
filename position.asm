.data
    # Display configuration
    displayWidth:  .word 16      # 256 pixels / 16 unit width = 16 units
    displayHeight: .word 32      # 512 pixels / 16 unit height = 32 units
    baseAddress:   .word 0x10010000
    
    # Square properties
    squareX:       .word 8       # Initial X position (0-15)
    squareY:       .word 16      # Initial Y position (0-31)
    squareColor:   .word 0x00FFFF00  # Yellow color
    
    # Saved positions
    savedPositions: .space 40    # Space for 10 addresses
    saveIndex:     .word 0
    
    # Keyboard
    keyboardAddress: .word 0xffff0000

.text
main:
    jal clear_display
    
    gameLoop:
        jal drawSquare
        jal checkKeyboard
        li $a0, 50
        li $v0, 32
        syscall
        jal clearSquare
        j gameLoop

    li $v0, 10
    syscall


# Fixed drawSquare function with proper bounds checking
drawSquare:
    lw $t0, baseAddress
    lw $t1, squareX
    lw $t2, squareY
    lw $t3, displayWidth
    lw $t4, squareColor
    
    # Ensure coordinates are within bounds
    bge $t1, $t3, endDraw   # If x >= width, skip
    lw $t5, displayHeight
    bge $t2, $t5, endDraw   # If y >= height, skip
    
    # Calculate address safely
    mul $t5, $t2, $t3       # y * width
    addu $t5, $t5, $t1      # + x
    sll $t5, $t5, 2         # *4
    addu $t5, $t5, $t0      # + base
    
    # Verify address is within display memory range
    lw $t6, baseAddress
    li $t7, 16
    mul $t7, $t7, 32         
    mul $t7, $t7, 4         
    addu $t7, $t6, $t7      # End address
    
    blt $t5, $t6, endDraw   # If below base, skip
    bge $t5, $t7, endDraw   # If above end, skip
    
    sw $t4, 0($t5)
    
    endDraw:
        jr $ra

# Fixed clearSquare function
clearSquare:
    lw $t0, baseAddress
    lw $t1, squareX
    lw $t2, squareY
    lw $t3, displayWidth
    li $t4, 0x00000000
    
    # Same safe calculation as drawSquare
    bge $t1, $t3, endClear
    lw $t5, displayHeight
    bge $t2, $t5, endClear
    
    mul $t5, $t2, $t3
    addu $t5, $t5, $t1
    sll $t5, $t5, 2
    addu $t5, $t5, $t0
    
    lw $t6, baseAddress
    li $t7, 16
    mul $t7, $t7, 32         
    mul $t7, $t7, 4
    addu $t7, $t6, $t7
    
    blt $t5, $t6, endClear
    bge $t5, $t7, endClear
    
    sw $t4, 0($t5)
    
    endClear:
        jr $ra

# Fixed checkKeyboard with proper movement bounds
checkKeyboard:
    lw $t0, keyboardAddress
    lw $t1, 0($t0)
    beq $t1, 0, noInput
    
    lw $t2, 4($t0)
    
    beq $t2, 0x42, savePosition  # Enter key
    beq $t2, 0xE0, moveUp
    beq $t2, 0xE1, moveDown
    beq $t2, 0xE2, moveLeft
    beq $t2, 0xE3, moveRight
    
    noInput:
        jr $ra
    
    moveUp:
        lw $t3, squareY
        blez $t3, noInput
        subiu $t3, $t3, 1
        sw $t3, squareY
        j noInput
    
    moveDown:
        lw $t3, squareY
        lw $t4, displayHeight
        subiu $t4, $t4, 1
        bge $t3, $t4, noInput
        addiu $t3, $t3, 1
        sw $t3, squareY
        j noInput
    
    moveLeft:
        lw $t3, squareX
        blez $t3, noInput
        subiu $t3, $t3, 1
        sw $t3, squareX
        j noInput
    
    moveRight:
        lw $t3, squareX
        lw $t4, displayWidth
        subiu $t4, $t4, 1
        bge $t3, $t4, noInput
        addiu $t3, $t3, 1
        sw $t3, squareX
        j noInput
    
    savePosition:
        lw $t0, baseAddress
        lw $t1, squareX
        lw $t2, squareY
        lw $t3, displayWidth
        
        # Safe address calculation
        mul $t4, $t2, $t3
        addu $t4, $t4, $t1
        sll $t4, $t4, 2
        addu $t4, $t4, $t0
        
        # Verify address is valid
        lw $t5, baseAddress
	li $t6, 16
    	mul $t6, $t6, 32         
    	mul $t6, $t6, 4
        addu $t6, $t5, $t6
        
        blt $t4, $t5, saveError
        bge $t4, $t6, saveError
        
        # Save to array
        lw $t5, saveIndex
        la $t6, savedPositions
        sll $t7, $t5, 2
        addu $t7, $t7, $t6
        
        sw $t4, 0($t7)
        
        # Update index
        addiu $t5, $t5, 1
        li $t7, 10
        blt $t5, $t7, noWrap
        li $t5, 0
    noWrap:
        sw $t5, saveIndex
    saveError:
        j noInput