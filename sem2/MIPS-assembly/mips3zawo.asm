.data
	printStartMsg: .asciiz "\nWpisz ilosc instrukcji: [1, 5]\n"
	printGetInstructionMsg: .asciiz "\nWpisz kolejne instrukcje: \n"
	printAllInputBadMsg: .asciiz "\nNie ma takiej instrukcji w zbiorze obslugiwanych instrukcji! Sproboj wpisac cala instrukcje jeszcze raz:\n"
	printAllInputBadMsg2: .asciiz "\nNieprawdilowa liczba argumentow! Sproboj wpisac cala instrukcje jeszcze raz: \n"
	printWrongRegisterMsg: .asciiz "\nTaki rejestr nie istnieje! Sproboj wpisac cala instrukcje jeszcze raz:\n"
	printOutputStackPrintMsg: .asciiz "\nWypisywanie stacka w odwrotnej kolejnosci: \n"
	printAllocatedMemoryMsg: .asciiz "\nIlosc zaalokowanych bajtow pamieci na stosie: "
	printNewLineMsg: .asciiz "\n"
	
	check1: .asciiz "ADD"
	check2: .asciiz "ADDI"
	check3: .asciiz "J"
	check4: .asciiz "NOOP"
	check5: .asciiz "MULT"
	check6: .asciiz "JR"
	check7: .asciiz "JAL"
	
	input: .space 64
	word1: .space 64
	word2: .space 64
	word3: .space 64
	word4: .space 64
	output: .space 64
	
#s0 -> curretnly inspected byte
#s1 -> word which are we on
#s2 -> zaklepany na cos nwm

#t0 -> int ile obrotow petli
#t1 -> input
#t2 -> output
#t3 -> word1
#t4 -> word2
#t5 -> word3
#t6 -> word4

#t7 -> word checker
	
.text
main:
	li $v0, 4 #print string
	la $a0, printStartMsg
	syscall
	
	li $v0, 5 #read interger
	syscall
	move $t0, $v0
	
	bgt $t0, 5, main
	
	li $v0, 4 #print string
	la $a0, printGetInstructionMsg
	syscall
	
	j start

# ======================= PODZIAL NA SLOWA PO SPACJACH ======================= 
	
start:
	li $v0, 8 #read string
	li $a1, 64 #bedzie rozmiaru 50
	la $a0, input #wczytamy go tutaj
	syscall
	
	li $s1, 0 #dosyc wazne
	
	la $t1, input #do t0
	la $t2, output #wynik
	la $t3, word1 #na slowa pojedyncze
	la $t4, word2
	la $t5, word3
	la $t6, word4
	
	j splitInput

splitInput:
	lb $s0, ($t1) #load first byte from ($t1) to $s0
	beq $s0, 10, correctInput
	addi $t1, $t1, 1

	beqz $s0, checkInput
	beq $s0, 32, createNewWord #dodaj do slowa jesli to spacja
	
	j addToWord
	
createNewWord:
	addi $s1, $s1, 1
	j splitInput
	
correctInput:
	sb $zero, ($t3)
	sb $zero, ($t4)
	sb $zero, ($t5)
	sb $zero, ($t6)
	j checkInput
	
# ======================= ADD TO WORD METHODS ======================= 

addToWord:
	beq $s1, 0, addToWord1
	beq $s1, 1, addToWord2
	beq $s1, 2, addToWord3
	beq $s1, 3, addToWord4
addToWord1:
	sb $s0, ($t3)
	addi $t3, $t3, 1
    	j splitInput
addToWord2:
	sb $s0, ($t4)
    	addi $t4, $t4, 1
    	j splitInput
addToWord3:
	sb $s0, ($t5)
    	addi $t5, $t5, 1
    	j splitInput
addToWord4:
	sb $s0, ($t6)
    	addi $t6, $t6, 1
    	j splitInput
    	
#  ======================= CHECK FIRST WORD ======================= 

allInputBad:
	li $v0, 4 #print string
	la $a0, printAllInputBadMsg
	syscall
	
	j start
	
allInputBad2:
	li $v0, 4 #print string
	la $a0, printAllInputBadMsg2
	syscall
	
	j start
checkInput:
	jal checkInput1
	jal checkInput2
	jal checkInput3
	jal checkInput4
	jal checkInput5
	jal checkInput6
	jal checkInput7
	j allInputBad

checkInput1:
	li $s3, 3
	la $t7, check1
	la $t3, word1
	j cmploop

checkInput2:
	li $s3, 3
	la $t7, check2
	la $t3, word1
	j cmploop

checkInput3:
	li $s3, 1
	la $t7, check3
	la $t3, word1
	j cmploop

checkInput4:
	li $s3, 0
	la $t7, check4
	la $t3, word1
	j cmploop

checkInput5:
	li $s3, 2
	la $t7, check5
	la $t3, word1
	j cmploop
	
checkInput6:
	li $s3, 1
	la $t7, check6
	la $t3, word1
	j cmploop
	
checkInput7:
	li $s3, 1
	la $t7, check7
	la $t3, word1
	j cmploop

cmploop:
    	lb      $s0,($t7)                   # get next char from str1
    	lb      $s2,($t3)                   # get next char from str2
    	bne     $s0, $s2, cmpne             # are they different? if yes, fly
	
    	beqz    $s0, cmpeq             
    	beqz    $s2, cmpeq             # at EOS? yes, fly (strings equal)

    	addi    $t7, $t7, 1                   # point to next char
    	addi    $t3, $t3, 1                   # point to next char
    	j       cmploop

# strings are not equal
cmpne:
    	jr $ra

# strings are equal
cmpeq:
	bne $s1, $s3, allInputBad2
	la $t1, input
    	j checkOtherWords
    	#j reverseOutputPointer
	
#======================= STARE LADOWANIE NA STACKA ======================= 

# addToStack:
#	lb $s0, ($t1) #load from word
#	beqz $s0, end
#	addi $t1, $t1, 1 #next byte
#	
#	addi $sp, $sp, -1 #next byte
#	sb $s0, 0($sp) #save byte to stack
#	
#	b addToStack
	
#======================= CHECK OTHER WORDS ======================= 

checkOtherWords: #first, check whether the other variables are legal
	li $s5, 44 #comma ','
	la $t7, word1
	lb $t9, 1($t7) #should be R if JR
	jal checkOtherWord2
	jal checkOtherWord3
	jal checkOtherWord4
	j reverseOutputPointer
checkOtherWord2:
	la $t7, word2
	lb $s0, ($t7)
	beq $s0, '$', registerRequirments
	jr $ra
checkOtherWord3:
	la $t7, word3
	lb $s0, ($t7)
	beq $s0, '$', registerRequirments
	jr $ra
checkOtherWord4:
	la $t7, word4
	lb $s0, ($t7)
	beq $s0, '$', registerRequirments
	jr $ra
registerRequirments:
	addi $t7, $t7, 1
	lb $s0, ($t7)
	
	seq $t8, $s0, '3'
	seq $t9, $t9, 'R'
	and $t8, $t9, $t8
	bnez $t8, jrCase #dla 31
	bnez $t9, unknownRegisters
	
	beq $s0, '8', leftCase #dla 8
	beq $s0, '9', leftCase #dla rejestru 9
	beq $s0, '1', midCase #dla 10-19
	beq $s0, '2', rightCase #dla 20-25
	
	b unknownRegisters
leftCase:
	addi $t7, $t7, 1
	lb $s0, ($t7)
	seq $s2, $s5, $s0
	seq $s3, $zero, $s0
	or $s2, $s2, $s3
	bne $s2, 1, unknownRegisters
	jr $ra
midCase:
	addi $t7, $t7, 1
	lb $s0, ($t7)
	blt $s0, '0', unknownRegisters
	bgt $s0, '9', unknownRegisters
	addi $t7, $t7, 1
	lb $s0, ($t7)
	seq $s2, $s5, $s0
	seq $s3, $zero, $s0
	or $s2, $s2, $s3
	bne $s2, 1, unknownRegisters
	jr $ra
rightCase:
	addi $t7, $t7, 1
	lb $s0, ($t7)
	blt $s0, '0', unknownRegisters
	bgt $s0, '5', unknownRegisters
	addi $t7, $t7, 1
	lb $s0, ($t7)
	seq $s2, $s5, $s0
	seq $s3, $zero, $s0
	or $s2, $s2, $s3
	bne $s2, 1, unknownRegisters
	jr $ra
jrCase:
	addi $t7, $t7, 1
	lb $s0, ($t7)
	blt $s0, '1', unknownRegisters
	bgt $s0, '1', unknownRegisters
	addi $t7, $t7, 1
	lb $s0, ($t7)
	seq $s2, $s5, $s0
	seq $s3, $zero, $s0
	or $s2, $s2, $s3
	bne $s2, 1, unknownRegisters
	jr $ra
unknownRegisters:
	li $v0, 4 #print string
	la $a0, printWrongRegisterMsg
	syscall
	j start
	
#======================= LOAD TO STACK ======================= 

reverseOutputPointer:
	addi $t1, $t1, 1 #next byte
	lb $s0, ($t1) #load from word
	bnez $s0, reverseOutputPointer
loadIntoStack:
	sub $t1, $t1, 1
	lb $s0, ($t1)
	beqz $s0, checkInstructionCount
	addi $sp, $sp, -1 #next byte
	sb $s0, 0($sp) #save byte to stack
	
	b loadIntoStack
checkInstructionCount:
	sub $t0, $t0, 1 #zmniejszamy n
	beqz $t0, end
	b start #wracamy na start od poczatku
	
#======================= WYPISAC WYNIK ZE STACKA ======================= 

end:

	li $v0, 4 #print string
	la $a0, printAllocatedMemoryMsg
	syscall

	li $v0, 1 #int wypisac
	li $s0, 0x7fffeffc #wartosc poczatkowa stack pointera
    	subu $a0, $s0, $sp
    	syscall
    	
    	li $v0, 4 #print string
	la $a0, printNewLineMsg
	syscall
    	
	j endLoop

endLoop:
    	lb $s0, ($sp)
    	beqz $s0, printOutput
    	addi $sp, $sp, 1
    
    	sb $s0, ($t2)
    	addi $t2, $t2, 1
    
    	j endLoop
printOutput:
	li $v0, 4 #print string
	la $a0, printOutputStackPrintMsg
	syscall

	li $v0, 4 #print string
	la $a0, output
	syscall
	
	li $v0, 10 #end program
	syscall
