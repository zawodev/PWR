.data
	printMsgStartMenu: .asciiz "1) a=(b+c)*d\n2) a=(b-c)/d\n3) a=(b-c)+d\n"
	printMsgTypeVariables: .asciiz "Wpisz kolejno zmienne: b, c oraz d\n"
	printMsgGameOver: .asciiz "Wynik tego dzialania to: "
	printMsgPlayAgain: .asciiz "\nCzy chcesz wykonac kolejne dzialanie?\n"
	printMsgInvalid: .asciiz "\nBledny numer dzialania, program zakonczony\n"
.text
main:
	li $v0, 4
	la $a0, printMsgStartMenu
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0
	
	beq $t0, 1, void1
	beq $t0, 2, void2
	beq $t0, 3, void3
	
	li $v0, 4
	la $a0, printMsgInvalid
	syscall
	
	#syscall to end program
	li $v0, 10
	syscall
	
printScores:
	#wypisanie wynikow
	li $v0, 4
	la $a0, printMsgGameOver
	syscall
	
	move $a0, $t5
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, printMsgPlayAgain
	syscall
	
	#wczytanie 0-1 czy grasz od nowa
	li $v0, 5
	syscall
	move $t0, $v0
	
	beq $t0, 1, main
	
	#syscall to end program
	li $v0, 10
	syscall
	
getVariables:
	li $v0, 4
	la $a0, printMsgTypeVariables
	syscall
	
	li $v0, 5
	syscall
	move $t1, $v0
	
	li $v0, 5
	syscall
	move $t2, $v0
	
	li $v0, 5
	syscall
	move $t3, $v0
	
	jr $ra
	
void1:
	jal getVariables
	add $t4, $t1, $t2
	mul $t5, $t4, $t3
	j printScores
	
void2:
	jal getVariables
	sub $t4, $t1, $t2
	div $t5, $t4, $t3
	j printScores
	
void3:
	jal getVariables
	sub $t4, $t1, $t2
	add $t5, $t4, $t3
	j printScores
	