# Formula: address = base_address + 4*(x + y*W)
# Where x (0-15), y (0-31)

# Example: Set unit at (x=5, y=10) to red
li $t0, 0x10010000  # Base address
li $t1, 5           # x-coordinate (0-15)
li $t2, 10          # y-coordinate (0-31)
li $t3, 16          # Width in units (W)

mul $t4, $t2, $t3   # y * W
add $t4, $t4, $t1   # + x
sll $t4, $t4, 2     # *4 (bytes per word)
add $t4, $t4, $t0   # + base address

li $t5, 0x000000FF  # Red color
sw $t5, 0($t4)      # Store color at calculated address