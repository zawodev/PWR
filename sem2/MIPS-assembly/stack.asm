.data
	word1: .asciiz "zawodev"
	word: .space 16
	output: .space 16
.text
main:
	li $v0, 8 #read string
	li $a1, 50 #bedzie rozmiaru 50
	la $a0, word #wczytamy go tutaj
	syscall
	
	la $t0, word
	la $t1, output
	
	j loop
	
loop:
	lb $t2, ($t0) #load from word
	beqz $t2, end
	addi $t0, $t0, 1 #next byte
	
	addi $sp, $sp, -1 #next byte
	sb $t2, 0($sp) #save byte to stack
	
	b loop
end:
	lb $t2, ($sp)
	beqz $t2, huj
	addi $sp, $sp, 1
	
	sb $t2, ($t1)
	addi $t1, $t1, 1
	
	j end
huj:
	li $v0, 4 #print string
	la $a0, output
	syscall
