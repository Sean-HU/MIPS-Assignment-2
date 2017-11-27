text
main:
	la $a0, hex_str
	li $a1, 10
	li $v0, 8						# read user input
	syscall

	add $t0, $zero, $zero			#initialize sum (which will eventually be the result)
	add $t1, $zero, $a0				# store address of hex string in $t1
	add $t2, $zero, $zero			# intialize length

# check for spaces before, between, and after digits
space_check:									
	lb $t3, ($t1)
	beq $t3, 10, error							# if there are no digits, display error message
	beqz $t3, error
	bne $t3, 32, check_for_space_after_char		# once a character is found that is not a space or \n,
	add $t1, $t1, 1
	b space_check
check_for_space_after_char:						# check for spaces after that character
	lb $t3, ($t1)
	beq $t3, 10, end_space_check				# if there are no spaces after that, proceed with the program
	beqz $t3, end_space_check
	beq $t3, 32, check_for_char_after_space		# if there is a space after that, check if there are anymore digits
	add $t1, $t1, 1
	b check_for_space_after_char
check_for_char_after_space:
	lb $t3, ($t1)
	beq $t3, 10, end_space_check				# if there are no more non-space characters, proceed with the program
	beqz $t3, end_space_check
	bne $t3, 32, error							# if there is a non-space character, display error message
	add $t1, $t1, 1
	b check_for_char_after_space
end_space_check:								
	add $t1, $zero, $a0							# reset address pointer
	
length_loop:
	lb $t3, ($t1)					# load a byte in hex string into $t3
	beq $t3, sub_length2			# if character is ',' branch to sub_length2
	beqz $t3, sub_length1			# if character is null, branch to sub_length
	beq $t3, 10, sub_length2		# if character is '\n' branch to sub_length2
	beq $t3, 32, skip_increment		# if the character is a space, do not increment length
	add $t2, $t2, 1					# increment length
skip_increment:
	addi $t1, $t1, 1				# move to the next character in the string,
	b length_loop					# and repeat
sub_length1:						# move length back 2 spaces, to represent the largest exponent
	sub $t2, $t2, 2
	j reset_address
sub_length2:						# move length back 1 space to represent the largest exponent
	sub $t2, $t2, 1
reset_address:
	bgt $t2, 7, error				# if length > 7 (largest possible exponent), display error message
	add $t1, $zero, $a0				# move pointer back to the first character