##########################################################################
#Created by:   Ahmed, Arib
#              aahmed
#              7 March 2019
#
# Assignment:  Lab 5: Subroutines
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2019
#
# Description: This program is a caser cipher.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

#The strings and arrays I need for the lab
.data

error: .asciiz "Invalid input: Please input E, D, or X\n"
edx: .space 1
keystring: .space 100
userinput: .space 100
resultstring: .space 100
mynameisjeff: .asciiz "Here is the encrypted and decrypted string\n"
encrypted: .asciiz "<Encrypted> "
decrypted: .asciiz "<Decrypted> "
newline: .asciiz "\n"

.text
#This is the first subroutine, it gives the first three prompts and reads the strings the user inputs.
give_prompt:

   beq $t1, 1, invalid1 #This is an error checker. $t3 is used incase the user inputs a wrong character. If it was invalid, it sets t1 to 1 to tell the code that they did. 
   move $t3, $a0 #Saves the first prompt into t3 incase the user puts a wrong input.
   beq $a1, 1, part2 #Checks if the main code is printing the second prompt
   beq $a1, 2, part3 #Checks if the main code is printing the third prompt.


      invalid1:
      
         li $t1, 0 #t1 is set back to 0 to show the computer that we need to reset the promps incase they mess up again.
         la $a0, ($t3) #Sets a0 back to the first prompt incase there was an error.
         li $v0, 4 #Allocating the syscall number to print a string
         la $a0, ($a0) #Sets a0 to the first promp
         syscall #Prints the prompt.
    
         li $v0, 8 #Allocating the syscal number to read a string
         la $a0, edx #Allocats one byte to the address, reading the character input
         li $a1, 3 #a1 has to be 3 since the user has to hit enter, creating a new line. 
         syscall #Prints the value.

         la $v0, edx #Sets $v0 to the character the user inputted.
      
errorcheck: #This is an error check if the character is not e d or x.

    lb $t0, edx #Loads the character into t0
    
    echeck:
    
       bne $t0, 69, dcheck #Checks if it is E
       j valid #If it is, it jumps to valid
    
    dcheck: #Checks if it is D, if it is, jumps to valid.
    
       bne $t0, 68, xcheck
       j valid
    
    xcheck: #Checks if it is X, if it is, jumps to valid
    
       bne $t0, 88, invalid
       j valid
    
    invalid: #If it is neither X, E, or D, the computer prints out a error message.
    
       li $v0, 4
       la $a0, error
       syscall
    
       li $t1, 1 #Sets t1 to 1 to tell the code that user messed up
       j give_prompt #jumps back to the beginning of the code.
    
    valid:
    
       jr $ra #Jumps back to the link 
    
part2:

    #Prints the second prompt
    li $v0, 4 
    la $a0, ($a0)
    syscall
    
    #Reads the second string
    li $v0, 8
    la $a0, keystring
    li $a1, 101
    syscall
    
  
    #Loads v0 with the keystring
    la $v0, keystring
    
    jr $ra #Jumps back to the link
    
part3:

    #Prints the third prompt
    li $v0, 4
    la $a0, ($a0)
    syscall
    
    #Reads the second string
    li $v0, 8
    la $a0, userinput
    li $a1, 101
    syscall
    
    #Loads v0 with the userinput
    la $v0, userinput
    
    
    jr $ra #Jumps back to the link
   
cipher: #This is the cipher, it shifts the characters one by one depending on the keysum
   
   
   sub $sp, $sp, 4 #Stores ra to stack
   sw $ra, ($sp) #pushes to stack
   jal compute_checksum #Jumps and links into compute checksum
   b startcode
   
   
   finishcode:
   
   lw $ra, 0($sp) #retrieve the ra needed
   addi $sp, $sp, 4 #pops the stack
   jr $ra #returns to the main
   
   startcode:
  
   move $t0, $v0 #Saves the checksum into t0
   move $t9, $v0 #Saves the checksum into t9

#Checks whether to encrypt or decrypt

   lb $a0, edx #Loads a0 with the character of e, d, or x.

checkencrypt:

   bne $a0, 69, exit1 #If the value is d, then it goes into the decrypt code.
   jal encrypt #Jumps and links to encrypt
   j finishcode #It jumps back to the main code after the value is encrypted.
   
exit1:

checkdecrypt:

   jal decrypt #Jumps and links to decrypt
   la $ra, ($t6) #The return address saved from before is now loaded into ra.
   j finishcode #It jumps back to the main code after the value is decrypted.

compute_checksum:

   sub $sp, $sp, 4 #saves to stack
   sw $ra, ($sp) #saves to stack
   li $t3, 0 #Loads t3 into 0 for the checksum.

   sumloop:

      lb $t0, ($a1) #Loads t0 into the first character
      lb $t1, 1($a1) #Loads t1 into the second character
      #If these characters are a newline or nothing, then the code exists, noting that the code is finished
      beq $t0, 0xa, exitsum 
      beq $t0, 0x0, exitsum
      beq $t1, 0xa, oddnum #If the code is odd, then it jumps to another program that allows us to xor the values together
      xor $t2, $t0, $t1 #Xor's t0 and t1 into t2
      xor $t3, $t3, $t2 #Xor's t2 and t3 into t3 so we can have the final result of all the xors.
      addi $a1, $a1, 2 #Increments the string by 2 so we can get the other characters

      j sumloop #Jumps back to the loop

   exitsum:

      div $v0, $t3, 26 #Mods the value by 26 so we can have a check sum that is between 0-26
      mfhi $v0 #Sets v0 to the checksum
      
      
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra #Jumps back to the return address.

encrypt:
   
   sub $sp, $sp, 4 #gets the right ra needed
   sw $ra, ($sp) #right ra needed
   
   move $t0, $a2 #Sets the value of the userinput into t0
   li $t8, 0 #Sets t8 t0 for a loop.
   
asciiloop:
   
   lb $t3, ($t0) #t3 is the first character of the userinput
   beq $t3, 0xa, exitascii #if it is a newline, it exits
   beq $t3, 0x0, exitascii #if it not existent, it exists
   jal check_ascii #jumps to checkascii
   
   exitcheck1:
   
      beq $v0, 0, rangeupper #If the return value is 0, goes to rangeupper
      beq $v0, 1, rangelower #If return value is 1, goes to lower
      beq $v0, -1, dontchange #If it -1, it goes to dont change
   
   j asciiloop

exitascii:

   beq $t5, 0x44, exitascii2 #t5 is equal to the character value, and jumps to exitascii if the character is D
   la $v0, resultstring #Loads the result into v0
   
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   
   jr $ra #Jumps back to the return address

decrypt:
   
   sub $sp, $sp, 4 #saves to stack
   sw $ra, ($sp) #saves to stack
   
   move $t0, $a2 #It loads t0 from a2
   li $t8, 0 #Sets t8 to 0 for a loop

asciiloop2:

   lb $t3, ($t0) #Loads t3 into the first character
   beq $t3, 0xa, exitascii #if it is a newline, it exits 
   beq $t3, 0x0, exitascii #if it not existent, it exists
   jal check_ascii #jumps to checkascii
   
   exitcheck2:
   
      beq $v0, 0, rangeupper2 #If the return value is 0, goes to rangeupper
      beq $v0, 1, rangelower2 #If return value is 1, goes to lower
      beq $v0, -1, dontchange2 #If it -1, it goes to dont change
   
   j asciiloop2 #jumps back to the loop

exitascii2:

   la $v0, resultstring #Saves the decrypted value into the resultstring
   lw $ra, 0($sp) #gets right ra
   addi $sp, $sp, 4 #pops th estack
   jr $ra #jumps back to the return address.

   
check_ascii:

    ble $t3, 0x40, notchar #Checks if t3 is not a character (in range)
    bge $t3, 0x7b, notchar #^^
    ble $t3, 0x5b, ifuppercase #Checks if t3 is uppercase (in range)
    ble $t3, 0x7a, iflowercase #Checks if t3 is lowercase (in range)
    bge $t3, 0x5b, ifnotchar #Checks if t3 is notchar (in range)
    
      ifnotchar:

         ble $t3, 0x60, notchar #if less, branches to notchar


      iflowercase:

         bge $t3, 0x61, lowercase #If greater, branches to lowercase
 

     ifuppercase:

         bge $t3, 0x41, uppercase #if greaterm branches to uppercase
       
            notchar:
   
               li $v0, -1 #Sets v0 to negative 1 if not a char
               beq $a0, 0x45, exitcheck1 #if a0 is E, jump to encrypting code
             
               j exitcheck2 #if a0 is D, jump to decrypting code

            uppercase:

               li $v0, 0 #sets v0 to 0 if uppercase
               beq $a0, 0x45, exitcheck1 #if a0 is E, jump to encrypting code
               j exitcheck2 #if a0 is D, jump to decrypting code

            lowercase:
 
              li $v0, 1 #Sets v0 to 1 if kowercase
              beq $a0, 0x45, exitcheck1 #if a0 is E, jump to encrypting code
              j exitcheck2 #if a0 is D, jump to decrypting code


   rangeupper: #Shifts if it is upper case, encryption
     
      add $t3, $t3, $t9 #Shifts the cipher by the checksum(encryption)
      bge $t3, 0x5b, reset #if it is above Z, then it jumps to reset
      sb $t3, resultstring($t8) #stores one character into the array
      addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
      addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
      j asciiloop #Jumps back to asciiloop
  
      reset: #encryption
     
         subi $t3, $t3, 26 #If it is above Z, itll reset it back to A, and add the rest back from the shift
         sb $t3, resultstring($t8) #stores one character into the array
         addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
         addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
         j asciiloop #Jumps back to asciiloop
     
   rangeupper2: #Decryption
     
      sub $t3, $t3, $t9 #Shifts the cipher by the checksum(decryption)
      ble $t3, 0x40, reset2 #if it is lower than A, then it jumps to reset
      sb $t3, resultstring($t8) #stores one character into the array
      addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
      addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
      j asciiloop2 #Jumps back to asciiloop
  
      reset2: #decryption
     
        addi $t3, $t3, 26 #if it less than A, it will reset it back to Z
        sb $t3, resultstring($t8) #stores one character into the array
        addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
        addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
        j asciiloop2 #Jumps back to asciiloop2
     
  rangelower: #Shifts if it is lowercase 
  
     add $t3, $t3, $t9 #Shifts the cipher by the checksum(encryption)
     bge $t3, 0x7b, reset1 #if it is above z, then it jumps to reset
     sb $t3, resultstring($t8) #stores one character into the array
     addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
     addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
     
     j asciiloop #Jumps back to asciiloop
  
      reset1:#encryption
   
         subi $t3, $t3, 26 #if it less than z, it will reset it back to a
         sb $t3, resultstring($t8) #stores one character into the array
         addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
         addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
         j asciiloop #Jumps back to asciiloop

  rangelower2:#decryption
     
     sub $t3, $t3, $t9 #Shifts the cipher by the checksum(decryption)
     ble $t3, 0x60, reset3 #if it is less than a, then it jumps to reset
     sb $t3, resultstring($t8) #stores one character into the array
     addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
     addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
     j asciiloop2 #Jumps back to asciiloop
  
     reset3:#decryption
     
        addi $t3, $t3, 26 #if it less than a, it will reset it back to z
        sb $t3, resultstring($t8) #stores one character into the array
        addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
        addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
        j asciiloop2 #Jumps back to asciiloop
     
   dontchange: #encryption
     
     sb $t3, resultstring($t8) #stores the same character into the array
     addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
     addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
     j asciiloop #Jumps back to asciiloop
    
   dontchange2: #decryption
     
     sb $t3, resultstring($t8) #stores the same character into the array
     addi $t8, $t8, 1 #adds t8, the counter of the array, by 1
     addi $t0 $t0, 1 #Adds t0, the counter of the userinput, by 1
     j asciiloop2 #Jumps back to asciiloop
    


oddnum:

   xor $t3, $t3, $t0 #If the keystring is odd, then it sets t3 to xor of t3 and t0 instead of xoring the character wiht 0xA

   j exitsum #jumps back to exitsum


print_strings:

   lb $t8, ($a2) #Loads t8 into the character of e, d, or x

   li $v0, 4 #Prints newline
   la $a0, newline
   syscall

   li $v0, 4 #Prints the encrypted and decrypted prompt
   la $a0, mynameisjeff
   syscall

   li $v0, 4 #Prints <Encrpted>
   la $a0, encrypted
   syscall


eif:

   beq $t8, 0x45, printe #if t8 is E, then it jumps to printe
   beq $t8, 0x44, printd #if t8 is D, then it jumps to printd

exitprint:

   li $v0, 4 #Prints <decrypted>
   la $a0, decrypted
   syscall

dif:

   beq $t8, 0x45, printe2 #If it is E, it jumps to that
   beq $t8, 0x44, printd2 #If D, jumps to taht

exitprint2:

   jr $ra #Jumps back to the main code

printe:

   li $v0, 4 #prints the resultstring
   la $a0, resultstring
   syscall

   li $v0, 4 #prints a newline
   la $a0, newline
   syscall

   j exitprint #jumps to exitprint

printd:

   li $v0, 4 #prints the userinput
   la $a0, userinput
   syscall

   j exitprint #jumps back to exitprint

printe2:

   li $v0, 4 #prints the userinput
   la $a0, userinput
   syscall

   j exitprint2 #jumps back to exitprint

printd2:

   li $v0, 4 #prints the resultstring
   la $a0, resultstring
   syscall

   li $v0, 4 #prints a newline
   la $a0, newline
   syscall
   
   j exitprint2 #jumps back to exitprint
   