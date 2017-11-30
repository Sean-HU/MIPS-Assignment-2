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