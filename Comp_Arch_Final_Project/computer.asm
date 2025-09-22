# 	FInal Project
#  	Author: Noel Varghese
#	Date: March 10, 2025
# 	Description: This program makes moves for the computer

.include "SysCalls.asm"
.data
.text
.globl compMove

# Make the computer's move
# $a0: first turn 0 - false, 1 - true
compMove:
	addi $sp, $sp, -4		# Save space on stack
	sw $ra, 0($sp)			# Save the return address
	
	move $t7, $a0			# Save first turn in $t7
	bnez $t7, Forced			# If 0 (false) run the normal ste
	Loop:				# while loop
	
		li $v0, SysGetTime		# SysCall: Get the current time
		syscall				# Running SysCall
	
		li $t0, 9				# Load Immediate: 9 (9 options in array)
		divu $a0, $t0			# Unsigned Division
		mfhi $t1				# Take the remainder (MOD)
		addi $t1, $t1, 1			# Add 1 -> 0-8 1->9
	
		li $v0, SysGetTime		# SysCall: Get the current time
		syscall				# Running SysCall
	
		li $t0, 2				# Load Immediate: 2 (2 options, UP or LP)
		divu $a0, $t0			# Unsigned Division
		mfhi $t2				# Take the remainder (MOD)
	
		move $a0, $t2 			# Give UP or LP
		move $a1, $t1			# Give new value
		li $a2, -1				# Computer's move 
		jal changeToken			# Change the token
	
		beqz $v0, Done			# If entered is good, then end computer's turn
		
		j Loop				# Loop Again
	
	Forced:					# If it forced
	
		li $v0, SysGetTime		# SysCall: Get the current time
		syscall				# Running SysCall
	
		li $t0, 9				# Load Immediate: 9 (9 options in array)
		divu $a0, $t0			# Unsigned Division
		mfhi $t1				# Take the remainder (MOD)
		addi $t1, $t1, 1			# Add 1 -> 0-8 1->9
	
		li $a0,  0	 			# Give LP
		move $a1, $t1			# Give new value
		li $a2, 0				# Computer's move
		jal changeToken			# Change the token 
	
	Done:					# Done
		lw $ra, 0($sp)			# Load return address
		addi $sp, $sp, 4			# Give space back to stack
		jr $ra					# return
	
