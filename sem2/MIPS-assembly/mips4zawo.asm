.data
	printStartMenuMsg: .asciiz "\nCo chcesz zrobic?\n1) Dodawanie\n2) Odejmowanie\n3) Mnozenie\n4) Dzielenie\n"
	printResultMsg: .asciiz "Wynik: "
	printVariablesMsg: .asciiz "\nPodaj swoje liczby ponizej.\n"
	printDivByZeroErrorMsg: .asciiz "Dzielenie przez zero nie jest dozwolone, wpisz inna liczbe\n" #nigdy cholero
	printRepeatMsg: .asciiz "\nCzy kontynuowac dzialania? [Y]\n"
	printUnknownCharMsg: .asciiz "\nNieznany znak - wprowadz jeszcze raz.\n"
	printFirstStringMsg: .asciiz "Pierwsza liczba:\n"
	printSecondStringMsg: .asciiz "Druga liczba:\n"
	printTooBigMsg: .asciiz "\nTa liczba nie miesci sie w mantysie.\n"
	printIncorrectChoiceErrorMsg: .asciiz "\nNiepoprawny wybor, wybierz jeszcze raz: \n"
	
	floatingException: .double 0.0
	floatingBase: .double 1.0
	floatingMovePoint:.double 10.0
	
	input1: .space 64
	input2: .space 64
.text
main:
	li $v0, 4
	la $a0, printStartMenuMsg
	syscall
	
	li $v0, 5 #wybor w menu dzialania
	syscall
	move $t0, $v0
	
	blt $t0, 1, incorrectChoiceError
	bgt $t0, 4, incorrectChoiceError
	
	li $v0, 4
	la $a0, printVariablesMsg
	syscall
	
	ldc1 $f14, floatingMovePoint

#==================================================================================
#				LOAD STRING 1
#==================================================================================

getString1:
	ldc1 $f4, floatingException #resetowanie zmiennych floatowych przy ponownym dzialaniu programu
	
	li $v0, 4 #print string
	la $a0, printFirstStringMsg
	syscall
	
	li $v0, 8 #read string
	li $a1, 1048 
	la $a0, input1 
	syscall
	
	la $t1, input1
	ldc1 $f10, floatingBase #ladowanie pnkt
	li $t4, 0 #nums
	j loop1
loop1: #zamiana na floaty
	beq $t4, 23, tooLongString1 #checking for char number in float
	lb $s0, ($t1)
	beq $s0, 10, getString2 #checking if string has ended
	beq $s0, 0, getString2 #checking if string has ended
	beq $s0, '.', pointer1 #kropka wy
	blt $s0, '0', unknownCharacter1 #nieznany znak
	bgt $s0, '9', unknownCharacter1 #nieznany znak
	subi $s0, $s0, 48
	mtc1 $s0, $f0 #converting from int to float
	cvt.d.w $f0, $f0
	mul.d $f6, $f10, $f0
	add.d $f4, $f4, $f6
	j add1
add1:
	add $t4, $t4, 1
	addi $t1, $t1, 1
	div.d $f10, $f10, $f14
	j loop1
pointer1:
	addi $t1, $t1, 1
	li $t5, 1
correct1String:  #correcting float so it takes in valueas greater than 9.(9)
	beq $t4, 0, unknownCharacter1
	beq $t5, $t4, loop1
	mul.d $f4, $f4, $f14
	mul.d $f10, $f10, $f14
	addi $t5, $t5, 1
	j correct1String
unknownCharacter1: #exception for wrong char
	li $v0, 4
	la $a0, printUnknownCharMsg
	syscall
	j getString1
tooLongString1: #exception for too long word
	li $v0, 4
	la $a0, printTooBigMsg
	syscall
	j getString1
	
#==================================================================================
#				LOAD STRING 2
#==================================================================================

getString2:
	ldc1 $f8, floatingException
	li $s4, 0
	li $v0, 4
	la $a0, printSecondStringMsg
	syscall
	li $v0, 8 #read string
	li $a1, 1048 
	la $a0, input2
	syscall
	la $t2, input2
	ldc1 $f10, floatingBase #loading stupid shit
	j loop2
loop2:
	beq $s4, 23, tooLongString2 #checking whether fits into mantyissa
	lb $s1, ($t2)
	beq $s1, 10, optionSelect
	beq $s1, 0, optionSelect #checking whether the string has ended
	beq $s1, '.', pointer2
	blt $s1, '0', unknownCharacter2
	bgt $s1, '9', unknownCharacter2
	subi $s1, $s1, 48
	mtc1 $s1, $f0
	cvt.d.w $f0, $f0
	mul.d $f6, $f10, $f0
	add.d $f8, $f8, $f6
	j add2
add2:
	addi $t2, $t2, 1
	div.d $f10, $f10, $f14
	addi $s4, $s4, 1
	j loop2
pointer2:
	addi $t2, $t2, 1
	li $s5, 1
correct2String: #correcting float for bigger vals
	beq $s4, 0, unknownCharacter2
	beq $s5, $s4, loop2
	mul.d $f8, $f8, $f14
	mul.d $f10, $f10, $f14
	addi $s5, $s5, 1
	j correct2String
unknownCharacter2:
	li $v0, 4
	la $a0, printUnknownCharMsg
	syscall
	j getString2
tooLongString2:
	li $v0, 4
	la $a0, printUnknownCharMsg
	syscall
	j getString2
	
#==================================================================================
#				     MAIN MENU
#==================================================================================

optionSelect:
	beq $t0, 1, ADD
	beq $t0, 2, SUB #branching based on chosen option
	beq $t0, 3, MUL
	beq $t0, 4, DIV
	j incorrectChoiceError

incorrectChoiceError:
	li $v0, 4 #print string
	la $a0, printIncorrectChoiceErrorMsg
	syscall
	 
	j main


#==================================================================================
#			       OPERACJE MATEMATYCZNE
#==================================================================================

ADD:
	add.d $f6, $f8, $f4 #doddawanie floatow
	j printResult
SUB:
	sub.d $f6, $f4, $f8 #odejmownnei floatow
	j printResult
MUL:
	mul.d $f6, $f8, $f4 #mnozenie floatow
	j printResult
DIV:
	ldc1 $f10, floatingException #loading for comparing in division
	c.eq.d $f8, $f10 #branch if equal on doubles to our contorl 0.0 double
	bc1t DIVEXC #branching based on condition of the flag 
	div.d $f6, $f4, $f8
	
	j printResult
DIVEXC: #dzielenie przez zero error
	la $v0, 4 # print string
	la $a0, printDivByZeroErrorMsg
	syscall
	
	j getString2
	
#==================================================================================
#			     END GAME (PLAY AGAIN?)
#==================================================================================

printResult:
	li $v0, 4 #print string
	la $a0, printResultMsg
	syscall
	
	li $v0, 3 #print float
	mov.d $f12, $f6
	syscall
	
	j playAgain

playAgain: #looping as always
	li $v0, 4 # print string
	la $a0, printRepeatMsg
	syscall
	
	li $v0, 12 #read char
	syscall
	
	#move $t1, $v0
	beq $v0, 'Y', main #play again?
	j end
end:
	li $v0, 10 #end program
	syscall
