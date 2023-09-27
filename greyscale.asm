.data
	filePathIn:	    .asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\Ass2\q2\input.ppm"
	filePathOut:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\Ass2\q2\out.ppm"
	fileWords:	    .space 1024
    digits:         .space 3
    line:           .asciiz "\n"
    file_Type:      .asciiz "P2"
.text
.globl main
main:
#Open file for read
	li $v0, 13
	la $a0, filePathIn
	li $a1,0                        # 0 is for read mode
	syscall
	move $s0, $v0	                # File descriptor

    #Open file for write
    li $v0, 13
    la $a0, filePathOut
    li $a1, 1                       # 1 is for write mode
    li $a2, 0
    syscall
    move $s1, $v0                   #File descriptor

	li $s2, 48                      #$s2= 48 ( 0 is ASCII)
    li $s7, 10
    move $t6, $zero                 # will ontain 3 degits at end of line
    li $t0, 1                       #  line checker
    li $t7, 1                       #3 RGB checker
    readLoop:
        # Read a file
		li $v0, 14
		move $a0, $s0
		la $a1, fileWords
		li $a2, 1                   #Single bit at a time 
		syscall

		beq $v0,$zero, close_files  #End of file

		la $s3, fileWords
        lb $t1, 0($s3)              #Value is ASCII

        beq $t1, 10, reset          #go to reset when we reach EOL
        ble $t0, 5, header          #go to header for first 3 lines

        
        sub $s4, $t1, $s2           #Current pixel Value in decimal format
        mul $t6, $t6, $s7
        add $t6, $t6, $s4           #Store each pixel as a decimal
       
 
    j   readLoop

    header:
             beq  $t0, 1, fileType
             beq $t0, 2, readLoop
            #write to file
            li $v0, 15
            move $a0, $s1
            la $a1, fileWords
            li $a2, 1
            syscall
        j readLoop

    fileType:
        li $v0, 15
            move $a0, $s1
            la $a1, file_Type
            li $a2, 2
            syscall
        addi   $t0, $t0,1
    j readLoop
    IntPart:
        # Do the operations
        add $t5, $t5, $t6
        beq $t7, 3, operation
        addi $t7, $t7, 1
        #reset
        li $t6, 0
    j readLoop

    operation:
        div $t4, $t5,3
         la $t3, digits
        jal storeToMeM
        li $t8,0
        trippleDo:
            beq $t8, 1, otherPix
            jal writeInt
            addi $t8, $t8, 1
         j trippleDo
        
    j readLoop

    otherPix:
        li $t6, 0
        li $t7, 1
        li $t5, 0
        li $t8, 0
    j   readLoop

	reset: 
        addi $t0, $t0, 1
        ble $t0, 6,header       #ensure that newline is appeneded on new file
        bge $t0, 4, IntPart
     
        
        j   readLoop


    storeToMeM:
            # Extract the 1st digit (e.g., '1')
            div $s3, $t4, 100  # Divide $t0 by 100 to get the hundreds digit
            mflo $t1           # Q
            addi $t1, $t1, 48   #Ensure Ascii value
        sb $t1, 0($t3)          # Store back to registor

        #Extract 2nd degit
        div $s5, $t4, 10 
        mflo $t2                 # Q( unit and tenth)
        divu $t2, $t2, 10
        mfhi $t1                 # 2nd degit
        addi $t3, $t3, 1         # Increment digit address
        addi $t1, $t1, 48        # Ensure Ascii value
        sb $t1, 0($t3)           # Store back to registor

        #Extract the 3rd degit
        div $s6, $t4, 10           # Divide $t0 by 10 to get the 3rd digit
        mfhi $t1                   # R
        addi $t3, $t3, 1           # Increment digit address
        addi $t1, $t1, 48          # Ensure Ascii value
        sb $t1, 0($t3)             # Store back to registor
    jr $ra

    writeInt:
        #Write to files
        li $v0, 15
		move $a0, $s1
        la $a1, digits   #contains 3 degits
        li $a2, 4
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