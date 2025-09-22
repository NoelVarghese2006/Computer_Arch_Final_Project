# 	FInal Project
#  	Author: Noel Varghese
#	Date: March 10, 2025
# 	Description: This program prints a visually indicator of the board and the pointers

.include "SysCalls.asm"  # Use SysCalls

.data
	.align 2 # alignment
	GameP: .word -1		# To save the original value of the pointer
	GameP2: .word -1		# To save the original value of the 2nd pointer
	
	TempP: .word -1		# Temporary Pointers
	TempP2: .word -1		# Temporary Pointers
	
	Board: .asciiz "01 02 03 04 05 06\n07 08 09 10 12 14\n15 16 18 20 21 24\n25 27 28 30 32 35\n36 40 42 45 48 49\n54 56 63 64 72 81\n\n"  # Inital board
	#Values: 1: 0, 2: 3, 3: 6 => 3n 
	GameArrow: .asciiz "                           V\n"	# Upper pointer UP
	GameArrow2: .asciiz "                           A\n"	# Lower pointer LP
	# Values: 1:0, 2:3, 3:6, 4:9, 5:12, 6:15, 7:18, 8:21, 9:24 X: 27
	# X(pointer) -> 1:27, 2:24 ... =  30 - 3(value)
	
	Markers: .asciiz "C O " 		# Markers for the board
	Array: .asciiz "1 2 3 4 5 6 7 8 9 X\n"	# Visual Indicator of where the pointers are 
.text
.globl drawBoard
.globl boardInit
.globl movePointer
.globl markBoard

# Initialize values that depend on string addresses
boardInit:
	la $t0, GameArrow		# Load Address of the arrow
	la $t1, GameArrow2		# Load address of 2nd arrow
	sw $t0, GameP			# Save location to a variable
	sw $t1, GameP2			# Save the other location to the other variable
	sw $t0, TempP			# Save location to a variable (temporary/shifing)
	sw $t1, TempP2			# Save the other location to the other variable (temporary/shifting)
	jr $ra					# return

	
# Print the board to the screen	
drawBoard: 				
	
	li $v0, SysPrintString		# SysCall: Print String
	la $a0, Board			# Argument: Board String
	syscall				# Running SysCall
	
	li $v0, SysPrintString		# SysCall: Print String
	lw $a0, TempP			# Get Pointer Location
	la $a0, 0($a0)			# Argument: Upper Pointer
	syscall				# Running SysCall
	
	li $v0, SysPrintString		# SysCall: Print String
	la $a0, Array			# Argument: Array
	syscall				# Running SysCall
	
	li $v0, SysPrintString		# SysCall: Print String
	lw $a0, TempP2			# Get Pointer Location
	la $a0, 0($a0)			# Argument: Lower Pointer
	syscall				# Running SysCall
	
	jr $ra					# Return
	
# $a0: which pointer 0 - UP 1 - LP
# $a1: new location
# Equation to move arrow properly is 30 - 3($a1)
movePointer:
	bnez $a0, MoveLP	# Moving LP ( $a0 == 1): go to that section
	
	# Move UP
	mul $t0, $a1, 3		# Multply by 3 and put in $t0
	sub $t0, $zero, $t0	# Make it negative
	addi $t0, $t0, 30		# Add 30
	lw $t1, GameP		# Get Address of the pointer string
	add $t1, $t1, $t0		# Move to desired spot
	sw $t1, TempP		# Move temporary pointer to new spot
	j mPEnd			# GO to end
	
	MoveLP:				# Move LP
		mul $t0, $a1, 3		# Multply by 3 and put in $t0
		sub $t0, $zero, $t0	# Make it negative
		addi $t0, $t0, 30		# Add 30
		lw $t1, GameP2		# Get Address of the pointer string
		add $t1, $t1, $t0		# Move to desired spot
		sw $t1, TempP2		# Move temporary pointer to new spot
	
	mPEnd:	
		jr $ra			# Return

# $a0 - who? -1 computer, -2 player
# $a1 - index, place on the board not the actual value (81 is in spot 35)
markBoard:
	la $t0, Board		# Get the board
	li $t1, -2			# Temp Val
	beq $a0, $t1, Player	# If player skip to player 
	mul $t1, $a1, 3		# Mult by 3
	add $t0, $t0, $t1		# add to index of board
	lb $t1, Markers		# Get the C char
	sb $t1, 0($t0)		# Set char of the board to C
	lb $t1, Markers+1	# Get the whitespace
	sb $t1, 1($t0)		# Set second char to whitespace
	jr $ra				# Return
	
	Player:				# Player's move
		mul $t1, $a1, 3		# Mult by 3
		add $t0, $t0, $t1		# add to index of board
		lb $t1, Markers+2	# Get the O char
		sb $t1, 0($t0)		# Set char of the board to O
		lb $t1, Markers+3	# Get the whitespace
		sb $t1, 1($t0)		# Set second char to whitespace
	
		jr $ra				# return
