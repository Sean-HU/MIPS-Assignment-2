.text
main:
	la $a0, hex_str
	li $a1, 10
	li $v0, 8						# read user input
	syscall

	add $t0, $zero, $zero			#initialize sum (which will eventually be the result)
	add $t1, $zero, $a0				# store address of hex string in $t1
	add $t2, $zero, $zero			# intialize length


error:
	la $a0, error_msg				# display error message if input is invalid
	li $v0, 4
	syscall
	j exit					
print_decimal:
	add $t9, $zero, 10				# store 10 in $t9
	divu $t0, $t9					# split the value into 2 halves
	mflo $t8						# store the first half in $t8
	mfhi $t9						# store the second half in $t9
	beqz $t8, print_2nd_half		# if the first half is 0, only print the second
	move $a0, $t8					# display first half
	li $v0, 1
	syscall
print_2nd_half:					
	move $a0, $t9					# display second half
	li $v0, 1
	syscall
	la $a0, new_line
	li $v0, 4
	syscall
exit:
	li $v0, 10						# exit
	syscall

	.data
hex_str: .space 10
new_line: .asciiz "\n"
error_msg: .asciiz "Invalid hexadecimal number."