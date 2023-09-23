.data
	filePathIn:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\sample_images\house_64_in_ascii_cr.ppm"
	filePathOut:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\sample_images\out1.ppm"
	fileWords:	.space 1024
.text
.globl main
main:
	#Use lb ans sb for simplification
	#Open file for readz
	li $v0, 13
	la $a0, filePathIn
	li $a1,0
	syscall
	move $s0, $v0	#File descriptor

    #Open file for write
    li $v0, 13
    la $a0, filePathOut
    li $a1, 1
    li $a2, 0
    syscall
    move $s1, $v0
	li $t0, 0
	li $t7, 48
	readLoop:
		li $v0, 14
		move $a0, $s0
		la $a1, fileWords
		li $a2, 1
		syscall

		beq $v0,$zero, close_files
		#bgt $t0, 13, incre

		#Write to files
		li $v0, 15
		move $a0, $s1
		la $a1, fileWords
		li $a2, 1
		syscall
		addi $t0, $t0, 1
	j readLoop

	# incre:
	# 	sub $a0, $a0, $t7
	# 	j readLoop


	# Print the value of lines avalailble
	addi $t0, $t0, -13
	li $t1, 3
	div $t0, $t1
	mfhi $t2
	li $v0, 1
	move $a0, $t0
	syscall
	
	close_files:	#Close file
		li $v0, 16
		move $a0, $s0
		syscall

		li $v0, 16
		move $a0, $s1
		syscall

exit:
	li $v0,	10
	syscall
