.data
	filePathIn:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\Ass2\q1\input.ppm"
	filePathOut:	.asciiz "C:\Users\NDXARI004\Documents\CSC2\MIPS\Ass2\q1\out.ppm"
    original:       .asciiz "Average pixel value of the original image:\n"
    new:               .asciiz "Average pixel value of new image:\n"
	fileWords:	.space 1024
    sum:        .word 1024
    digits:        .space 3
    line:   .asciiz "\n"
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
    li $t4, 0                       #sum for new image
    li $t7, 0                       #sum for original image

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
        blt $t0, 4, header          #go to header for first 3 lines
        
        sub $s4, $t1, $s2           #Current pixel Value in decimal format
        mul $t6, $t6, $s7
        add $t6, $t6, $s4           #Store each pixel as a decimal
       
 
    j   readLoop

        header:
            #write to file
            li $v0, 15
            move $a0, $s1
            la $a1, fileWords
            li $a2, 1
            syscall
        j readLoop

    IntPart:
        # ensure pixel is less or equal 255
        add $t7, $t7, $t6
        bge $t6, 255, stayTheSame
        blt $t6, 255, IncrePix
    j readLoop

    stayTheSame:
        li $t6, 255

        la $t3, digits
        jal storeToMeM      #Write the 3 degits into memory as decimal
        jal writeInt

        #reset

        li $t6, 0
    j   readLoop

    IncrePix:
        addi $t6, $t6, 10          #Increment each pixel by 10
        la $t3, digits
        jal storeToMeM
        jal writeInt

        #reset
        li $t6, 0
    j   readLoop


	reset: 
        addi $t0, $t0, 1
        ble $t0, 4,header       #ensure that newline is appeneded on new file
        bge $t0, 4, IntPart
        
        j   readLoop
	

    storeToMeM:
            # Extract the 1st digit (e.g., '1')
            div $s3, $t6, 100  # Divide $t0 by 100 to get the hundreds digit
            mflo $t1           # Q
            addi $t1, $t1, 48   #Ensure Ascii value
        sb $t1, 0($t3)          # Store back to registor

        #Extract 2nd degit
        div $s5, $t6, 10 
        mflo $t2                 # Q( unit and tenth)
        divu $t2, $t2, 10
        mfhi $t1                 # 2nd degit
        addi $t3, $t3, 1         # Increment digit address
        addi $t1, $t1, 48        # Ensure Ascii value
        sb $t1, 0($t3)           # Store back to registor

        #Extract the 3rd degit
        div $s6, $t6, 10           # Divide $t0 by 10 to get the 3rd digit
        mfhi $t1                   # R
        addi $t3, $t3, 1           # Increment digit address
        addi $t1, $t1, 48          # Ensure Ascii value
        sb $t1, 0($t3)             # Store back to registor

        add $t4, $t4, $t6       #Add pixel values
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

    output:
        li $t0, 64
        li $t1, 255
        li $t3, 3

        mul $t2, $t0, $t0
        mul $t2, $t2, 3			# Value to use for 64x64x3
        
        mtc1 $t2, $f2
        cvt.s.w $f2, $f2			# t2 is now float f2
        
        mtc1 $t4, $f4
        cvt.s.w $f4, $f4		        # sum for new image(as float)

        mtc1 $t7, $f8
        cvt.s.w $f8, $f8                # sum for original image(as float)
        
        mtc1 $t1, $f1
        cvt.s.w $f1, $f1			# 255 is now float
        
        #Original image
        div.s $f9, $f8, $f2             # Avg pixels
        div.s $f10, $f9, $f1            # to get a value between 0 and 1 
        #new image
        div.s $f6, $f4, $f2   			 
        div.s $f7, $f6, $f1  		       

            #print output message 2
        li $v0,4
        la $a0, original
        syscall

            #print average of new image pixels
        li $v0, 2
        mov.s $f12, $f10
        syscall

        #newLine
        li $v0, 4
        la $a0, line
        syscall

            #print output message 2
        li $v0,4
        la $a0, new
        syscall

            #print average of new image pixels
        li $v0, 2
        mov.s $f12, $f7
        syscall
exit:
	li $v0,	10
	syscall
