.data
	printGameCountMsg: .asciiz "\nwybierz ilosc gier z zakresu [1, 5]\n"
	printXorOMsg: .asciiz "\nwybierz X lub O\n"
	printGiveSquareMsg: .asciiz "\npodaj pole [1, 9]\n"
	printWinMsg: .asciiz "\nwygral: "
	printWinnersMsg: .asciiz "\nzwyciezcy gier:"
	printDrawMsg: .asciiz "\nremis"
	printEnemyTurnMsg: .asciiz "\ntura przeciwnika: \n"
		
	printErrorMsg1: .asciiz "\nliczba nie jest w zakresie [1, 5]\n"
	printErrorMsg2: .asciiz "\npole jest juz zajete - wybierz inne pole\n"
	printErrorMsg3: .asciiz "\nmusisz podac znak X lub O\n"
	printErrorMsg4: .asciiz "\nliczba nie jest w zakresie [1, 9]\n"
	
	output: .space 100
	output2: .space 100
.text
#=======================================================
#t0 -> ile rund [1, 5]
#t1 -> char X or O
#t2 -> [1, 9] wybor pola
#t3 -> tura counter [1 - 9]
#t4 -> enemy X or O
#t5 -> wygrany symbol

#t6, t7, t8, t9 -> temp -> korzystaj kiedy chcesz

#s0 -> tablica 1

main:
	li $v0, 4 #print string
	la $a0, printGameCountMsg
	syscall

	li $v0, 5 #read int
	syscall
	move $t0, $v0 #t0 -> ile rund
	
	jal check1
	j main2

main2:
	li $v0, 4 #print string
	la $a0, printXorOMsg
	syscall
	
	li $v0, 12 #read char
	syscall
	move $t1, $v0 #t1 -> X or O
	
	# X + O = 88 + 79 = 167
	seq $t9, $t1, 'X' #88
	seq $t8, $t1, 'O' #79
	li $t4, 88
	mul $t9, $t4, $t9
	li $t4, 79
	mul $t8, $t4, $t8
	add $t8, $t8, $t9
	li $t4, 167
	sub $t4, $t4, $t8
	#chyba odwrotny znak w t4 bedzie teraz
	
	jal check2
	
	#lui $s0, 0x23B8 #tablica s0 na pola 1-9
	#ori $s0, $s0, 0xF000
	li $s0, 0x10018888
	
	j game
drawCase:
	la $t9, printDrawMsg
	jal addToStack
	
	j game
game:
	li $t3, 5
	#print round result
	
	jal s0clear
	
	beqz $t0, end
	addi $t0, $t0, -1 #loop counter
	
	j nextRound
nextRound:
	li $v0, 4 #print string
	la $a0, printGiveSquareMsg
	syscall
	
	li $v0, 5 #read int
	syscall
	move $t2, $v0 #t2 -> pole ktore gramy
	
	jal check3
	
	jal checkWin
	
	jal printGUI #print round gui
	
	addi $t3, $t3, -1 #loop counter
	beqz $t3, drawCase #remis jesli nikt nie wygral
	
	jal enemyTurn
	
	li $v0, 4 #print string
	la $a0, printEnemyTurnMsg
	syscall
	
	jal checkWin
	
	jal printGUI #print round gui
	
	j nextRound
#=======================================================	
notInRangeError:
	li $v0, 4 #print string
	la $a0, printErrorMsg1
	syscall
	j main
notInRangeError2:
	li $v0, 4 #print string
	la $a0, printErrorMsg3
	syscall
	j main2
notInRangeError3:
	li $v0, 4 #print string
	la $a0, printErrorMsg4
	syscall
	j nextRound
occupiedFieldError:
	li $v0, 4 #print string
	la $a0, printErrorMsg2
	syscall
	j nextRound
check1: #t0 in range of [1, 5]
	blt $t0, 1, notInRangeError
	bgt $t0, 5, notInRangeError
	jr $ra
check2: #t1 only [X or O]
	seq $t8, $t1, 'X'
	seq $t9, $t1, 'O'
	or $t8, $t8, $t9 
	beqz $t8, notInRangeError2
	jr $ra
check3: #t2 in range of [1, 9]
	blt $t2, 1, notInRangeError3
	bgt $t2, 9, notInRangeError3
	
	sll $t8, $t2, 2 #mnozenie przez 4
	add $t8, $t8, $s0 #index ktory chcemy sprawdzic
	#move $t8, $s0 #copy index adress
	#add $t8, $t8, $t2 #index ktory chcemy sprawdzic
	lw $t9, 0($t8) #wczytujemy do t9
	
	#li $v0, 1
    	#add $a0, $t9, $zero
    	#syscall
    	bnez $t9, occupiedFieldError
	
	sw $t1, 0($t8) #zapisz do tablicy X or O #$t1 zamiast t9 jesli nwm cos
	
	jr $ra
	
#=======================================================

s0clear: #czysci tablice
	li $t9, 1
	j s0loop
s0loop:
	sll $t8, $t9, 2 #mnozenie przez 4
	add $t8, $t8, $s0 #index ktory chcemy sprawdzic
	sw $zero, 0($t8) #wczytujemy zero na index

	addi $t9, $t9, 1 #loop counter
	beq $t9, 10, jreturn
	j s0loop

#=======================================================

printGUI: #wypisuje gui
	li $t9, 1
	la $t6, output
	
	j guiloop
guiloop:
	sll $t8, $t9, 2 #mnozenie przez 4
	add $t8, $t8, $s0 #index ktory chcemy sprawdzic
	lw $t7, 0($t8) #wczytujemy zero na index
	beqz $t7, g1
	j g2
g1:
	li $t7, '#'
	j g2
g2:
	sb $t7, ($t6)
	addi $t6, $t6, 1
	li $t7, 3
	div $t9, $t7
	mfhi $t7
	beqz $t7, g3
	j g4
g3:
	li $t7, '\n'
	sb $t7, ($t6)
	addi $t6, $t6, 1
	j g4
g4:
	addi $t9, $t9, 1 #loop counter
	bgt $t9, 9, loopend
	j guiloop
loopend:
	li $t7, 0
	sb $t7, ($t6)
	
	li $v0, 4 #print string
	la $a0, output
	syscall
	
	j jreturn

#=======================================================

enemyTurn:
	li $t9, 1
	j enemyLoop
enemyLoop:
	sll $t8, $t9, 2 #mnozenie przez 4
	add $t8, $t8, $s0 #index ktory chcemy sprawdzic
	lw $t7, 0($t8) #wczytujemy zero na index
	
	beqz $t7, enemyFinish

	addi $t9, $t9, 1 #loop counter
	beq $t9, 10, jreturn
	j enemyLoop

enemyFinish:
	sw $t4, 0($t8)
	j jreturn

#=======================================================

checkWin:
	# XXX
	# ###
	# ###
	lw $t9, 4($s0)
	lw $t8, 8($s0)
	lw $t7, 12($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# ###
	# XXX
	# ###
	lw $t9, 16($s0)
	lw $t8, 20($s0)
	lw $t7, 24($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# ###
	# ###
	# XXX
	lw $t9, 28($s0)
	lw $t8, 32($s0)
	lw $t7, 36($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# X##
	# X##
	# X##
	lw $t9, 4($s0)
	lw $t8, 16($s0)
	lw $t7, 28($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# #X#
	# #X#
	# #X#
	lw $t9, 8($s0)
	lw $t8, 20($s0)
	lw $t7, 32($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# ##X
	# ##X
	# ##X
	lw $t9, 12($s0)
	lw $t8, 24($s0)
	lw $t7, 36($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
	
	# X##
	# #X#
	# ##X
	lw $t9, 4($s0)
	lw $t8, 20($s0)
	lw $t7, 36($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win

	# ##X
	# #X#
	# X##
	lw $t9, 12($s0)
	lw $t8, 20($s0)
	lw $t7, 28($s0)
	seq $t8, $t8, $t9
	seq $t7, $t7, $t9
	and $t7, $t7, $t8
	sne $t8, $t9, $zero
	and $t7, $t7, $t8
	bnez $t7, win
			
	j jreturn
	
win:
	move $t5, $t9 # save to t5
	jal printGUI #print round gui

	li $v0, 4 #print string
	la $a0, printWinMsg
	syscall
	
	li $v0, 11 #print int
	move $a0, $t5
	syscall
	
	addi $sp, $sp, -1 #next byte
	sb $t5, 0($sp) #save byte to stack
	
	la $t9, printWinMsg
	jal addToStack
	
	
	j game

#=======================================================

jreturn:
	jr $ra

#======================= LOAD TO STACK ======================= 

addToStack:
	addi $t9, $t9, 1 #next byte
	lb $t8, ($t9) #load from word
	bnez $t8, addToStack
loadIntoStack:
	sub $t9, $t9, 1
	lb $t8, ($t9)
	beqz $t8, jreturn
	addi $sp, $sp, -1 #next byte
	sb $t8, 0($sp) #save byte to stack
	b loadIntoStack
	
#======================= WYPISAC WYNIK ZE STACKA ======================= 

end:
	la $t9, output2
	j endLoop

endLoop:
    	lb $t8, ($sp)
    	beqz $t8, printOutput
    	addi $sp, $sp, 1
    
    	sb $t8, ($t9)
    	addi $t9, $t9, 1
    
    	j endLoop
printOutput:
	li $v0, 4 #print string
	la $a0, printWinnersMsg
	syscall

	li $v0, 4 #print string
	la $a0, output2
	syscall
	
	li $v0, 10 #end program
	syscall
	
