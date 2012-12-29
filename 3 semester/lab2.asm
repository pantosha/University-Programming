; ------------------------------------------------------------------------------
; Деление введённых целых чисел друг на друга. С выводом результата ;
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------

.model small
.stack 100h
.386
.data
	strend		db		10, 13, 'Введите делимое: ', '$'
	strer 		db		10, 13, 'Введите делитель: ', '$'
	strout 		db		10, 13, 'Получите частное: ', '$'
	buffer		db		05h, 6 dup (?)
	endstring	db		'$'
	
.code
start:

	mov AX, @data
	mov DS, AX
	;mov ES, AX

; Main

delimoe:
; Выводим строку "Введите делимое: "
	mov AX, offset strend
	call print

; Получаем делимое
	mov AX, offset buffer
	call getString
	
; Преобразуем делимое в hex
	mov AX, offset buffer
	inc AX
	inc AX
	call str2Num
	
	test AX, AX
	je delimoe

; Выталкиваем его на будущее в стек	
	push AX

delitel:
; Выводим строку, но уже о делителе
	mov AX, offset strer
	call print

; Получаем сам делитель
	mov AX, offset buffer
	call getString

; Опять конвертируем
	mov AX, offset buffer
	inc AX
	inc AX
	call str2Num
	
	test AX, AX
	je delitel
	
	push AX
	
	mov AX, offset strout
	call print	
	
	pop BX
	pop AX
	
	xor DX, DX
	div BX
	mov DX, offset buffer
	call num2Str
	
	jmp theend
	
; Print string. Pointer in AX
print proc
	push DX
	
	mov DX, AX
	mov AH, 9h
	int 21h
	
	pop DX
	ret
print endp

; String in. In AX pointer at the begin of buffer
getString proc
	push DX
	push BX
	
	mov DX, AX
	mov AH, 0Ah
	int 21h
	
; Put '$' in the end of string
	xor BX, BX
	mov BL, byte ptr DS:[buffer + 1]
;	mov AL, endstring
	mov byte ptr [buffer + BX] + 2, 00h
	
	pop BX
	pop DX
	ret
getString endp

str2Num proc
	push BX
	push SI
	mov SI, AX
;	mov byte ptr DS:[SI + 4], 00h
	xor BX, BX
	cld ; сброс DF в ноль.
	
convert:
	LODS byte ptr DS:[SI]

	sub AL, '0'
	cmp AL, 9d
	ja not_digit
	imul BX, 10d
	add BX, AX
	jmp convert
	
not_digit:
	mov AX, BX
	pop SI
	pop BX
	ret
str2Num endp

; в AX - число
; в DX - буфер
num2Str proc
	push BX
	push DI

	mov DI, DX
	xor DX, DX
	mov DL, byte ptr DS:[DI]
	inc DL
	add DI, DX
	mov BL, endstring
	mov byte ptr DS:[DI], BL

	mov BX, 0Ah ; наша разрядность
cycle:
	xor DX, DX
	div BX
	add DX, '0'
	dec DI
	mov byte ptr DS:[DI], DL
	test AX, AX
	jne cycle
	
	mov DX, DI
	mov AH, 09h
	int 21h
	
	pop DI
	pop BX
num2Str endp

theend:
	mov ah, 4ch
	int 21h
end start