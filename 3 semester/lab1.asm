; ------------------------------------------------------------------------------
; Даны пять чисел. От четвёртого по возрастанию отнять третье. ;
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------
.model small
.stack 100h
.data
	arr db 10d, 20d, 11d, 4d, 23d
.code
start:
	mov SI, 4 ; общий счётчик циклов

	mov AX, @data
	mov DS, AX
	xor AX, AX
	
	lea BX, arr

for_i:
	mov AL, byte ptr DS:[BX + SI]
	xor DI, DI
for_j:
	cmp SI, DI
	jb exit_for_j; DX == CX
	cmp AL, byte ptr DS:[BX + DI]
	jnb no_swap
	xchg AL, byte ptr DS:[BX + DI]
	mov byte ptr DS:[BX + SI], AL
no_swap:
	inc DI
	jmp for_j
exit_for_j:
	dec SI
	cmp SI, 0h
	jne for_i
	
	mov AL, DS:[BX + 3]
	sub AL, DS:[BX + 2]

mov ah, 4ch
int 21h
end start