; ------------------------------------------------------------------------------
; Ввести строку, поменять порядок слов в предложении
; (мама мыла раму => раму мыла мама),
; вывести полученную строку
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------

.model small
.stack 100
.386
.data
	sHello 		db		'Введите строку не более 255 символов:', 0Ah, 0Dh, '$'
	buffer		db		0FFh, 0FFh dup (?)
	sByeBye		db		0Ah, 0Dh, 'Слова в обратном порядке:', 0Ah, 0Dh
	outbuffer	db		0FFh dup (?)
.code
assume DS: @data, ES: @data
start:

	mov AX, @data
	mov DS, AX
	mov ES, AX

	lea DX, sHello 
	call print ; Выводим строку с просьбой ввести строку)

	lea DX, buffer
	call read ; Считываем строку, которую будем обрабатывать

	call analyze ; Выполняем условие нашего задания

	lea DX, sByeBye ; И выводим результат
	call print

	jmp exit

; ----------
; Procedures
; ----------

; Print string
print proc
; In DX - string
	push AX
	pushf
	
	mov AH, 9h
	int 21h
	
	pop AX
	popf
	ret
print endp

; Get string
read proc
; In DX - special buffer
	pushf	
	push AX
	
	mov AH, 0Ah
	int 21h
	
	pop AX
	popf
	ret
read endp

; решение задания сходу
analyze proc
	xor CX, CX
	mov SI, offset outbuffer ; вспомогательная строка "куда"
	lea DI, buffer + 1
	mov CL, byte ptr DS:[DI] ; длина строки
	test CL, CL ; пустота строки
	je pend ; и прыжок
	
	add DI, CX

	mov AL, ' '
skipspace:
	std
	repe scasb
	je pend ; выходим, коль строка состоит из одних пробелов
	
; длина строки
	mov BX, CX
	inc BX ; теперь конец текущего слова лежит в BX
	repne scasb
	jne copy ; произойдёт прыжок, если перед словом не будет пробела
	inc DI	; вся эта сложная конструкция необходима для подавления разницы 
	inc CX
copy:
	sub BX, CX
	xchg BX, CX
	
; copy string
	cld
	xchg DI, SI
	push SI ; откуда начнём на следующем цикле
	inc SI
	rep movsb
	
; add space
	stosb
	;mov byte ptr DS:[DI], '$'
; в SI - строка "куда"
	mov SI, DI
	
	pop DI
	
	mov CX, BX
	test CX, CX
	jne skipspace
	
	dec SI
	
pend:
	mov byte ptr DS:[SI], '$'
	ret
analyze endp

exit:
	mov ah, 4ch
	int 21h
end start