# 	FInal Project
#  	Author: Noel Varghese
#	Date: April 28, 2025
# 	Description: Main program that starts and ends the game

.include "SysCalls.asm"
.data
	IntroPrompt: .asciiz "Welcome to the Multiplication Game (MIPS edition)!\nTry to get 4 in a row before the computer.\nTo move a token, type in this format =>\nFrom: {From}\nTo: {To}.\nExample:\n4\n9\nmoves the token from 4 to 9\nO represents your tokens\nC represents the computer's tokens\n" # Prompt for Instructions	
	Border: .asciiz "\n======================================\n" # Border for Visibility
	CompMove: .asciiz "Computer's Turn: \n\n"			# Indicate's Computer's turn
	PlayerMove: .asciiz "Your Turn: \n\n"				# Indicate's Player's turn
	StartMove: .asciiz "Here is the board: \n\n"			# Shows the board
	CompWon: .asciiz "Computer got 4 in a row!\n"		# Computer won prompt
	PlayerWon: .asciiz "You got 4 in a row!\n"			# player won prompt
.text
.globl main
main:				# Main module
	jal boardInit		# Initialize some values to store in drawboard class
		
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, IntroPrompt	# Argument: Introduction/Instruction Prompt
	syscall			# Running SysCall
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, Border		# Argument: Turn Divder
	syscall			# Running SysCall
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, StartMove	# Argument: Start text
	syscall			# Running SysCall
	
	jal drawBoard		# Run Procedure: drawBoard
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, Border		# Argument: Turn Divder
	syscall			# Running SysCall
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, CompMove	# Argument: Computer's Turn text
	syscall			# Running SysCall
	
	li $a0, 1			# indicate that it is the computer's first turn
	jal compMove		# Computer's move
	
	jal drawBoard		# Redraw Board
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, Border		# Argument: Turn Divder
	syscall			# Running SysCall
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, PlayerMove	# Argument: Player text
	syscall			# Running SysCall
	
	li $a0, 0			# Indicate its the first move
	jal playerMove		# run procedure
	
	jal drawBoard		# Draw the board
	
	li $v0, SysPrintString	# SysCall: Print String
	la $a0, Border		# Argument: Turn Divder
	syscall			# Running SysCall
	
	GameLoop:			# Normal Loop after first turn
		li $v0, SysPrintString	# SysCall: Print String	
		la $a0, CompMove	# Argument: Computer's Turn text
		syscall			# Running SysCall
	
		li $a0, 0			# indicate that it is not the computer's first turn
		jal compMove		# Computer's move
	
		jal drawBoard		# Redraw Board
		
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, Border		# Argument: Turn Divder
		syscall			# Running SysCall
		
		jal checkWin		# Check for a winner
		
		li $t0, 1				# temp value
		beq $v0, $t0, EndGame1	# if computer won, end game
	
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, PlayerMove	# Argument: Player text
		syscall			# Running SysCall
	
		li $a0, 1			# Indicate it is not the player's first move
		jal playerMove		# Player's move
		
		jal drawBoard		# Draw the board
		
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, Border		# Argument: Turn Divder
		syscall			# Running SysCall
		
		jal checkWin		# Check for a winner
		
		li $t0, 2				# Temp Value
		beq $v0, $t0, EndGame2	# If value returned is 2, jump to endgame2 (player won)
		
		j GameLoop		# Game loop
	
	EndGame1:			# Computer Won
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, CompWon	# Argument: computer won text
		syscall			# Running SysCall		
		
		li $v0, SysExit		# SysCall: Exit
		syscall			# Running SysCall
	
	EndGame2:			# Player Won
		li $v0, SysPrintString	# SysCall: Print String
		la $a0, PlayerWon	# Argument: Player won text
		syscall			# Running SysCall		
		
		li $v0, SysExit		# SysCall: Exit
		syscall			# Running SysCall
		
