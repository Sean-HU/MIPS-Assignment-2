#
	
	text
main:
	la $a0, hex_str
	li $a1, 10
	li $v0, 8						# read user input
	syscall
	add $s0, $zero, $a0				# store address of list of hex string in $s0
main_loop:
	add $s1, $s0, $zero				# store address of list of hex string in $s1 as well
find_end:
	lb $t0, ($s1)
	beq $s1, 44, end_find			# when $t0 is ',' end search
	beq $s1, 10, end_find			# when $t0 is '\n' end search
	beqz $s1, end_find				# when $t0 is null end search
	add $s1, $s1, 1					# otherwise, repeat
end_find:
	addi $sp, $sp, -12				# adjust stack for 2 items
	add $a0, $s0, $zero				# pass the beginning of hex val
	jal subprogram_2
	sw $s1, 8($sp)
	jal subprogram_3

subprogram_2:
	add $t0, $zero, $zero
	add $t1, $zero, $a0				# store address of hex string in $t1
	add $t2, $zero, $zero			# intialize length
	sw $ra, 0($sp)					# save return address
	# check for spaces before, between, and after digits
space_check:									
	lb $t3, ($t1)
	beq $t3, 10, nan							# if there are no digits, display error message
	beq $t3, 44, nan
	beqz $t3, nan
	bne $t3, 9, check_if_not_space1				# if character is not a tab, check if it's neither a space
	b dont_check
check_if_not_space1:
	bne $t3, 32, check_for_space_after_char		# once a character is found that is not a space, \t, nor \n,
dont_check1:
	add $t1, $t1, 1
	b space_check
check_for_space_after_char:						# check for spaces after that character
	lb $t3, ($t1)
	beq $t3, 44, end_space_check
	beq $t3, 10, end_space_check				# if there are no spaces after that, proceed with the program
	beqz $t3, end_space_check
	beq $t3, 9, check_for_char_after_space
	beq $t3, 32, check_for_char_after_space		# if there is a space after that, check if there are anymore digits
	add $t1, $t1, 1
	b check_for_space_after_char
check_for_char_after_space:
	lb $t3, ($t1)
	beq $t3, 10, end_space_check				# if there are no more non-space characters, proceed with the program
	beqz $t3, end_space_check
	beq $t3, 44, end_space_check
	bne $t3, 9, check_if_not_space2
	b dont_check2
check_if_not_space2:
	bne $t3, 32, nan							# if there is a non-space character, display error message
dont_check2:
	add $t1, $t1, 1
	b check_for_char_after_space
end_space_check:								
	add $t1, $zero, $a0							# reset address pointer
	
length_loop:
	lb $t3, ($t1)					# load a byte in hex string into $t3
	beqz $t3, sub_length1			# if character is null, branch to sub_length
	beq $t3, 10, sub_length2		# if character is '\n' branch to sub_length2
	beq $t3, 44, sub_length2		# if character is '\t' branch to sub_length2
	beq $t3, 32, skip_increment		# if the character is a space, do not increment length
	beq $t3, 9, skip_increment		# if the character is a tab, do not increment length
	add $t2, $t2, 1					# increment length
skip_increment:
	addi $t1, $t1, 1				# move to the next character in the string,
	b length_loop					# and repeat
sub_length1:						# move length back 2 spaces, to represent the largest exponent
	sub $t2, $t2, 2
	b reset_address
sub_length2:						# move length back 1 space to represent the largest exponent
	sub $t2, $t2, 1
reset_address:
	bgt $t2, 7, too_large			# if length > 7 (largest possible exponent), display error message
	add $t1, $zero, $a0				# move pointer back to the first character

# check_loop verifires each character in the hex string
check_loop:
	add $t4, $zero, $zero			# initialize power
	add $t5, $zero, 1				# set x to 1
	lb $t3, ($t1)					# load byte from address
	add $a0, $t3, $zero
	add $a1, $t1, $zero
	jal subprogram_1
	add $t6, $zero, $v0
	beq $t6, -1, nan
	beq $t6, 16, check_loop
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

nan:
	la $a0, nan_msg				# get address of "NaN"
	add $t0, $zero, $a0			# store address in $t0
	b return_full_int
too_large:
	la $a0, too_large_msg		# get address of "too large"
	add $t0, $zero, $a0			# store address in $t0
return_full_int:
	sw $t0, 4($sp)
	lw $ra, 0($sp)
	jr $ra



subprogram_1:
	add $t3, $a0, $zero
	add $t1, $a1, $zero
check_characters1:					
	beq $t3, 32, skip_char			# if character is a space,
	beq $t3, 9, skip_char			# or /t,
	j check_characters2


check_characters2:					
	add $t8, $zero, 48				# set $t8 to the character, '0'
	add $t6, $zero, $zero			# set mult to 0
check_numbers:
	beq $t8, 58, end_check_numbers	# when $t8 is outside the range of '0'-'9', check for letters
	beq $t3, $t8, set_int		# when character is found, go back to power_loop
	add $t8, $t8, 1					# increment $t8
	add $t6, $t6, 1					# increment mult
	b check_numbers
end_check_numbers:
	add $t8, $zero, 65				# set $t8 to the character, 'A'
	add $t9, $zero, 97				# set $t9 to the charatcer, 'a'
check_letters:
	beq $t8, 71, invalid_char		# if the character in the string is not a hexadecimal character, display error message
	beq $t3, $t8, set_int		# when character is found, go back to power_loop
	beq $t3, $t9, set_int		# when character is found, go back to power_loop
	add $t8, $t8, 1					# increment $t8
	add $t9, $t9, 1					# increment $t9
	add $t6, $t6, 1					# increment mult
	b check_letters					# and repeat
invalid_char:
	add $v0, $zero, -1
	b return_char
skip_char:
	add $v0, $zero, 16
	b return_char
set_int:
	add $v0, $t6, $zero
return_char:
	jr $ra
	
subprogram_3:
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	
	
	.data
comma: ","
hex_str: .space 1001
new_line: .asciiz "\n"
nan_msg: .asciiz "NaN"
too_large_msg: .asciiz "too large"
