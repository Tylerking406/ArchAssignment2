.data
	filePathIn:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\input.txt"
	filePathOut:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\out.txt"
	fileWords:	.space 1024
    Int:        .word 0
    line:   .asciiz "\n"
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
	li $t7, 48
    li $t5, 10      #The value to add so help create string int
	li $t3, 0		#line counter

    move $t6, $zero 
	readLoop:
		li $v0, 14
		move $a0, $s0
		la $a1, fileWords
		li $a2, 1
		syscall

		beq $v0,$zero, close_files
		#bgt $t0, 13, incre

		la $t4, fileWords
        lb $t1, 0($t4)          #Value is ASCII
        beq $t1, 10, reset      #When we reach end of the line we set t6=0

        sub $t2, $t1, $t7      #Current Int Value
        mul $t6, $t6, $t5
        add $t6, $t6, $t2
 
        j   readLoop

	# incre:
	# 	sub $a0, $a0, $t7
	# 	j readLoop


	reset:  #Also increBy10
        #Increment by 10
		addi $t3, $t3,1
        addi $t6, $t6, 10

        #Write it to file
        jal write

        sb $t6, Int

        #Write to files
		li $v0, 15
		move $a0, $s1
        la $a1, Int
        li $a2, 1
		syscall

        #rest
        li $t6, 0
        
        j   readLoop
	

    write:
        #print to screen for now
        li $v0, 1
        move $a0, $t6
        syscall

        #new Line
        li $v0, 4
        la $a0, line
        syscall
    jr $ra

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
