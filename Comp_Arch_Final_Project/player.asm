# 	FInal Project
#  	Author: Noel Varghese
#	Date: April 28, 2025
# 	Description: This program handles user input

.include "SysCalls.asm"
.data
	MoveF: .asciiz "From: "	# From Prompt
	MoveT: .asciiz "To: "		# To Prompt
	ErrorPrompt: .asciiz "Enter a value that a pointer is alread pointing to.\n"	# From error text
	ErrorPrompt2: .asciiz "Enter a value in range 1-9.\n" 	# To error text
	ErrorPrompt3: .asciiz "Number you tried to mark has already been marked on the board.\n" # Selection error text
	Newline: .asciiz "\n" # Newline char
.text
.globl playerMove

# Move Validation for the Player
# If $a0 == 0, skip the from
playerMove:
	addi $sp, $sp, -4		# Save space on stack
	sw $ra, 0($sp)			# Save the return address
	
	li $t0, 0			# Temp value
	beq $a0, $t0, TLoop	# if $a0 == 0, skip the from
	
	FLoop:				# Loop for From: 
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, MoveF		# Argument: From prompt
		syscall			# Running SysCall
	
		li $v0, SysReadInt	# SysCall: Read Int
		syscall			# Running SysCall
		move $t0, $v0		# Save to $t0
	
		move $a0, $t0		# give read value
		jal getToken		# check if either token UP/LP is pointing to entered number
	
		move $t0, $v0		# Save result in $t0
		li $t1, -1			# Temp value
		bne $t0, $t1, TLoop	# if $t0 is not -1, continue to TLoop
	
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, ErrorPrompt	# Argument: error1
		syscall			# Running SysCall
	
		j FLoop			# Ask Again
	
	TLoop:				# Loop for To:
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, MoveT		# Argument: To prompt
		syscall			# Running SysCall
	
		li $v0, SysReadInt	# SysCall: Read Int
		syscall			# Running SysCall
		move $t1, $v0		# Save to $t1
		
		blt $t1, 10, Valid		# If entered value <10, go the lower bound check
		
		OutofRange:			# If value out of range
			li $v0, SysPrintString	# SysCall: Print String
			la $a0, ErrorPrompt2	# Argument: error2
			syscall			# Running SysCall
			
			j TLoop 			# ask again
		Valid:				# Value is <10
			blt $t1, 1, OutofRange	# If <1 go to error prompting
		
		move $a0, $t0 		# Give UP or LP
		move $a1, $t1		# Give new value
		li $a2, -2			# Indicates Player's move 
		jal changeToken		# Change the token
		
		bne $v0, -2, END	# if no seleciton error END
		
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, ErrorPrompt3	# Argument: error3
		syscall			# Running SysCall
			
		j FLoop 			# ask again
		
		
	END:					# Done
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, Newline		# Argument: newline
		syscall			# Running SysCall
	
		lw $ra, 0($sp)			# Load return address
		addi $sp, $sp, 4			# Give space back to stack
	
		jr $ra					# return
		
