# 	FInal Project
#  	Author: Noel Varghese
#	Date: March 10, 2025
# 	Description: This program stores the pointer's location, marks the board, and checks for a winner (basically all the math for the game)

.include "SysCalls.asm"
.data
	.align 2	# alignment
	UP: .word -1 # Upper pointer
	LP: .word -1 # Lower pointer
	arr: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81 	# The real gameboard
.text
.globl changeToken
.globl getToken
.globl checkWin

# Find out of either token is pointing to a number
# $a0 value looking for
# $v0 - 0 => UP, 1 => LP, -1 => Neither
getToken:
	lw $t0, UP				# get value of UP
	lw $t1, LP				# get value of LP
	beq $a0, $t0, Pass1		# if UP == argument go to Pass1
	beq $a0, $t1, Pass2		# if LP == argument go to Pass2
	li $v0, -1				# Neither => output -1
	jr $ra					#r eturn
	Pass1:
		li $v0, 0			# UP has it so 0
		jr $ra				# return
	Pass2:
		li $v0, 1			# LP has it so 1
		jr $ra				# return

# Moves a pointer to a new number
# $a0 - Upper or Lower Token --- 0 UP, 1 LP
# $a1 - New Value
# $a2 - Who's moving? : 0 - First move (force), -1 Comp, -2 Player
# $v0, error checking: 0 - Success, 1 - Token already set to val, 2 - UP * LP has already been marked
changeToken:
	addi $sp, $sp, -4		# Save space on stack    
	sw $ra, 0($sp)			# Save the return address
	
	lw $t0, UP				# Load UP Value
	lw $t1, LP				# Load LP Value
	beqz $a2, NoCheck		# If force, go to NoCheck
	
	beqz $a0, UPCheck		# If Upper Value, do UP check
	j LPCheck				# Else do LP check
	
	UPCheck:				# Check if UP is already new value
		beq $t0, $a1, Error1	# If equal go to error1	
		move $t0, $a1		# Set to new value
		j Check2			# Go to board check
		
	LPCheck:				# Check if LP is already new value
		beq $t1, $a1, Error1	# If so go to error1
		move $t1, $a1		# Set to new value
		j Check2			# Otherwise go to second check
		
	
	Check2:					# Check if the value is already marked
		mul $t2, $t0, $t1			# Multiply UP and LP to get target value
		li $t3, 36				# Size of arr
		la $t4, arr				# Load arr address
		li $t5, 0				# Load a counter register
		Loop:				# For Loop
			lw $t6, 0($t4)		# Load next word
			beq $t6, $t2, Fin2	# if current value = target value finish, the value still is unmarked, go to fin2
			addi $t5, $t5, 1		# add one to counter
			beq $t5, $t3, Error2	# if counter reaches 36 end
			addi $t4, $t4, 4		# add 4 to arr pointer
			j Loop			# loop again
			
	NoCheck:					# Force change (for first move)
		move $t1, $a1			# set lower pointer to new value		
		j Fin					# Jump to sucess end
	
	Fin:					# Forced Finish
		sw $t0, UP			# Save to UP
		sw $t1, LP			# Save to LP

		li $a0, 1			# Indicate Moving LP
		move $a1, $t1		# GIve new value
		jal movePointer		# run procedure to move the pointer on the visual board
		j cTEnd			# jump to end sequence
	Fin2:
		sw $t0, UP			# Save to UP
		sw $t1, LP			# Save to LP
		sw $a2, 0($t4)		# Value is now stored in the place of where the multiplied value (-1 for comp) (-2 for player)
		# Change pointer $a0 set to 0 or 1
		beqz $a0, zero		# If $a0 is zero, go to zero
		move $a1, $t1		# give the LP value
		j end				# Skip to end
		zero:			
			move $a1, 	$t0	# Give UP value
		end:
		jal movePointer		# move pointer on visual board 
		
		move $a0, $a2		# Arg 1: Computer or Player
		move $a1, $t5		# Arg 2: what value to mark
		jal markBoard		# Mark the board
		
		
	cTEnd:				# Proper end
		lw $ra, 0($sp)			# Load return address
		addi $sp, $sp, 4			# Give space back to stack
		li $v0, 0			# 0 indicates a sucess
		jr $ra				# return
		
	Error1:				# Error1: UP/LP is already = to paramter
		lw $ra, 0($sp)		# Load return address
		addi $sp, $sp, 4		# Give space back to stack
		li $v0, -1			# -1 to indicate type of error (same val)
		jr $ra				# return
		
	Error2:				# Error2: UP*LP already marked
		lw $ra, 0($sp)		# Load return address
		addi $sp, $sp, 4		# Give space back to stack
		li $v0, -2			# -2 to indicate type of error (already picked)
		jr $ra				# return



# Check to see if there is 4 in a row
# $v0, 1 - Computer Won, 2 - Player Won, -1 - neither
checkWin:
	la $s0, arr 			# Keep the orig position
	la $t0, arr			# outer iterator
	li $t1, 4			# Size for wind
	move $t2, $zero		# In a Row Counter
	move $t3, $zero		# inner iterator
	li $t4, -2			# store -2
	li $t5, -1			# store -1
	
	
	BigLoop:				# Main loop
		lw $t6, 0($t0)		# get current word			
		beq $t6, $t4, MatchA	# if -2 find matches for player
		beq $t6, $t5, MatchB	# if -1 find matches for comptuer
	BigLoopCont:			# A breakpoint in loop
		addi $t0, $t0, 4		# next word
		sub $t7, $t0, $s0  	# find index
		beq $t7, 144, WinFalse 	# Go to winfalse, out of bounds
		j BigLoop			# Loop
		
	MatchA:				# If looking for player
		move $s1, $t4		# Save that value
		j Match			# Start checking
	MatchB:				# If looking for computer
		move $s1, $t5		# Save that value 
		j Match			# Start checking
	
	WinFalse:				# No matches
		li $v0, -1			# no 4 in a row
		jr $ra				# return
	
	WinTrue:				# There is a 4 in a row
		abs $v0, $s1		# $v0 = either 1 or 2
		jr $ra				# return
	
	Match:					# Look for 4 in a row
		li $t2, 1				# reset $t2 to 1
		move $t3, $t0			# Give temp pointer where $t0 is
		LoopH:				# Look for 4 in a row horizontally
			beq $t1, $t2, BoundH 	# Do Bounds checking if $t2 == 4
			addi $t3, $t3, 4		# next word
			sub $t7, $t3, $s0	# find index in relation to $t8
			beq $t7, 144, Vert	# make sure index is less that 144
			lw $t6, 0($t3)		# Load word in index
			bne $s1, $t6, Vert	# Not equal check next combo
			addi $t2, $t2, 1		# Equal: Add 1
			j LoopH			# Loop
		
	Vert:						# Look fro 4 in a row vertically
		li $t2, 1				# reset $t2 to 1
		move $t3, $t0			# Give temp pointer where $t0 is
		LoopV:				# Vertical Loop
			beq $t1, $t2, BoundV 	# Do Bounds checking if $t2 == 4
			addi $t3, $t3, 24		# next word (vertically)
			sub $t7, $t3, $s0		# find index in relation to $t8
			beq $t7, 144, LDiag	# make sure index is less that 144
			lw $t6, 0($t3)		# Load word in index
			bne $s1, $t6, LDiag	# Not equal check next combo
			addi $t2, $t2, 1		# Equal: Add 1
			j LoopV			# Loop
	
	LDiag:					# Check left diagonal
		li $t2, 1				# reset $t2 to 1
		move $t3, $t0			# Give temp pointer where $t0 is
		LoopLD:				# LD Loop
			beq $t1, $t2, BoundLD 	# Do Bounds checking if $t2 == 4
			addi $t3, $t3, 20		# next word (left diagonal)
			sub $t7, $t3, $s0		# find index in relation to $t8
			beq $t7, 144, RDiag	# make sure index is less that 144
			lw $t6, 0($t3)		# Load word in index
			bne $s1, $t6, RDiag	# Not equal check next combo
			addi $t2, $t2, 1		# Equal: Add 1
			j LoopLD			# Loop		  

	RDiag:					# Check right diagonal
		li $t2, 1				# reset $t2 to 1
		move $t3, $t0			# Give temp pointer where $t0 is
		LoopRD:		
			beq $t1, $t2, BoundRD 	# Do Bounds checking if $t2 == 4
			addi $t3, $t3, 28		# next word (left diagonal)
			sub $t7, $t3, $s0	# find index in relation to $t8
			beq $t7, 144, BigLoopCont	# make sure index is less that 144
			lw $t6, 0($t3)			# Load word in index
			bne $s1, $t6, BigLoopCont	# Not equal check next combo
			addi $t2, $t2, 1		# Equal: Add 1
			j LoopRD			# Loop	
			
	BoundH:					# Bound for horizontal: first index must have a (index)%6 < 3
		sub $t7, $t0, $s0		# find index in relation to $s0
		divu $t8, $t7, 4			# get word version of start index
		li $t9, 6				# Temp value
		divu $t8, $t9			# Divide by 6
		mfhi $t8				# get remainder
		li $t9, 3				# temp value
		blt $t8, $t9, WinTrue		# if remainder less than 3
		j Vert					# Try vertical
		
	BoundV:					# Bound for vertical: first index must be < 17
		sub $t7, $t0, $s0		# find index in relation to $s0
		divu $t8, $t7, 4			# get word version of start index
		li $t9, 18				# temp vale
		blt $t8, $t9, WinTrue		# if start index is 0-17, win
		j LDiag				# Try left diag
		
	BoundLD:					# Bounds: index < 17 and index%6 > 2 
		sub $t7, $t0, $s0		# find index in relation to $s0
		divu $t8, $t7, 4			# get word version of start index
		li $t9, 6				# Temp value
		divu $t8, $t9			# Divide by 6
		mfhi $t8				# get remainder
		li $t9, 2				# temp value
		bgt $t8, $t9, LDPrt2		# if remainder more than 2
		j RDiag					# Try right diag
		
		LDPrt2:					# Check index
			sub $t7, $t0, $s0		# find index in relation to $s0
			divu $t8, $t7, 4			# get word version of start index
			li $t9, 18				# temp vale
			blt $t8, $t9, WinTrue		# if start index is 0-17, win
			j RDiag				# Try right diag
			
	BoundRD:					# Bounds: index < 17 and index%6 < 3 
		sub $t7, $t0, $s0		# find index in relation to $s0
		divu $t8, $t7, 4			# get word version of start index
		li $t9, 6				# Temp value
		divu $t8, $t9			# Divide by 6
		mfhi $t8				# get remainder
		li $t9, 3				# temp value
		blt $t8, $t9, RDPrt2		# if remainder more than 2
		j BigLoopCont			# Try no matches at the index, move on
		
		RDPrt2:					# Check index
			sub $t7, $t0, $s0		# find index in relation to $s0
			divu $t8, $t7, 4			# get word version of start index
			li $t9, 18				# temp vale
			blt $t8, $t9, WinTrue		# if start index is 0-17, win
			j BigLoopCont			# Try no matches at the index, move on
			