.data
	filePathIn:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\input.txt"
	filePathOut:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\out.txt"
	fileWords:	.space 1024
    digits:        .space 3
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
    move $t6, $zero 
    li $t0, 1

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
        blt $t0, 4, header
        
        sub $t2, $t1, $t7      #Current Int Value
        mul $t6, $t6, $t5
        add $t6, $t6, $t2
 
    j   readLoop

        header:
            li $v0, 15
            move $a0, $s1
            la $a1, fileWords
            li $a2, 1
            syscall
        j readLoop

    IntPart:
        bge $t6, 255, stayTheSame
        blt $t6, 255, IncrePix
    j readLoop

    stayTheSame:
        li $t6, 255
          la $t3, digits
        jal storeToMeM
       
        #Write to files
        li $v0, 15
		move $a0, $s1
        la $a1, digits
        li $a2, 4
		syscall

        #rest
        li $t6, 0
    j   readLoop

    IncrePix:
         addi $t6, $t6, 10
           la $t3, digits
        jal storeToMeM
       
        #Write to files
        li $v0, 15
		move $a0, $s1
        la $a1, digits
        li $a2, 4
		syscall

        #rest
        li $t6, 0
    j   readLoop


	reset:  #Also increBy10
        addi $t0, $t0, 1
        ble $t0, 4,header       #ensure that newline is appeneded on new file
        bge $t0, 4, IntPart
        #li $t3, 0
        
        j   readLoop
	

    storeToMeM:
            # Extract the 1st digit (e.g., '1')
            div $s3, $t6, 100  # Divide $t0 by 100 to get the hundreds digit
            mflo $t1            # Q
            addi $t1, $t1, 48
        sb $t1, 0($t3)

        #Extract 2nd degit
        div $s5, $t6, 10  # 
        mflo $t2            # Q( unit and tenth)
        divu $t2, $t2, 10
        mfhi $t1             #2nd degit
        addi $t3, $t3, 1
        addi $t1, $t1, 48
        sb $t1, 0($t3)

        #Extract the 3rd degit
        div $s6, $t6, 10  # Divide $t0 by 100 to get the hundreds digit
        mfhi $t1            # R
        addi $t3, $t3, 1
        addi $t1, $t1, 48
        sb $t1, 0($t3)

        # #new Line
        # li $v0, 15
		# move $a0, $s1
        # la $a1, digits
        # li $a2, 3
		# syscall

        # li $v0, 15
		# move $a0, $s1
        # la $a1, line
        # li $a2, 1
		# syscall
       
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
