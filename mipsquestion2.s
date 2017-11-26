.text
main:
	la $a0, hex_str
	li $a1, 10
	li $v0, 8						# read user input
	syscall

	add $t0, $zero, $zero			#initialize sum (which will eventually be the result)
	add $t1, $zero, $a0				# store address of hex string in $t1
	add $t2, $zero, $zero			# intialize length

# check for spaces before, between, and after digits
subprogram_2:									
	lb $t3, ($t1)
	beq $t3, 10, error							# if there are no digits, display error message
	beqz $t3, error
	bne $t3, 32, check_for_space_after_char		# once a character is found that is not a space or \n,
	add $t1, $t1, 1
	b subprogram_2
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

# check_loop verifires each character in the hex string
check_loop:
	add $t4, $zero, $zero			# initialize power
	add $t5, $zero, 1				# set x to 1
	lb $t3, ($t1)					# load byte from address
	j subprogram_1				# check what the character is
power_loop:
	beq $t4, $t2, end_power_loop	# if power == length, then end loop
	mulou $t5, $t5, 16				# x = x * 16
	addi $t4, $t4, 1				# increment power
	b power_loop					# and repeat
end_power_loop:
	beqz $t2, set_x_to_one			# if the string entered had only one character,
	j sum
set_x_to_one:
	addi $t5, $zero, 1				# set x to 1
sum:
	mulou $t7, $t5, $t6				# product = x * mult
	add $t0, $t0, $t7				# sum += product
	addi $t1, $t1, 1				# increment address to move to the next character
	beqz $t2, print_decimal			# when length is 0, print decimal and exit
	sub $t2, $t2, 1					# decrement length
	b check_loop					# repeat check_loop


exit:
	li $v0, 10						# exit
	syscall

subprogram_1:					
	beq $t3, 32, end_check			# if character is a space,
	j check_characters2
end_check:
	add $t1, $t1, 1					# ignore it, move to the next character, 
	b check_loop					# and repeat check_loop
check_characters2:					
	add $t8, $zero, 48				# set $t8 to the character, '0'
	add $t6, $zero, $zero			# set mult to 0
check_numbers:
	beq $t8, 58, end_check_numbers	# when $t8 is outside the range of '0'-'9', check for letters
	beq $t3, $t8, power_loop		# when character is found, go back to power_loop
	add $t8, $t8, 1					# increment $t8
	add $t6, $t6, 1					# increment mult
	b check_numbers
end_check_numbers:
	add $t8, $zero, 65				# set $t8 to the character, 'A'
	add $t9, $zero, 97				# set $t9 to the charatcer, 'a'
check_letters:
	beq $t8, 71, error				# if the character in the string is not a hexadecimal character, display error message
	beq $t3, $t8, power_loop		# when character is found, go back to power_loop
	beq $t3, $t9, power_loop		# when character is found, go back to power_loop
	add $t8, $t8, 1					# increment $t8
	add $t9, $t9, 1					# increment $t9
	add $t6, $t6, 1					# increment mult
	b check_letters					# and repeat