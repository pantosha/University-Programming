;{-------------------------------------------------------------------------------------------------;
; Модификация предыдущей лабы "Деление введённых целых чисел друг на друга. С выводом результата" ;
; encoding CP-866																				  ;
;-------------------------------------------------------------------------------------------------;}

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

; Main

delimoe:
; Выводим строку "Введите делимое: "
	mov AX, offset strend
	call print

; Получаем делимое
	mov DI, offset buffer
	call getNumber
	
	test AX, AX
	je delimoe
	
	push AX

delitel:
; Выводим строку, но уже о делителе
	mov AX, offset strer
	call print

; Получаем сам делитель
	mov DI, offset buffer
	call getNumber
	
	test AX, AX
	je delitel
	
	push AX
	
; Вывод строки: "Получите частное: "
	mov AX, offset strout
	call print
	
	pop BX
	pop AX
	
	cwd
	idiv BX
	
	mov DI, offset buffer
	call num2Str
	
	jmp theend
	
; Print string. Pointer in AX
print proc
	push DX
	pushf
	
	mov DX, AX
	mov AH, 9h
	int 21h
	
	popf
	pop DX
	ret
print endp

; String in. In DI pointer at the begin of buffer
getNumber proc
	push DX
	push BX
	pushf
	
	mov DX, DI
	mov AH, 0Ah
	int 21h
	
; Put 00h in the end of string
	push DI
	xor BX, BX
	
	inc DI ; теперь DI указывает на длину буфера
	mov BL, byte ptr DS:[DI]
	inc DI ; DI установлен на начало значений
	mov byte ptr [DI + BX], 00h
	
	mov SI, DI
	call str2Num
	
	pop DI
	popf
	pop BX
	pop DX
	ret
getNumber endp

; Конвертация строки в число. Парсинг, по-нашему
; Входные переменные:
; 	SI - буфер со строкой для конвертации, оканчивающийся нулём
; Выходные переменные:
; 	AX - полученное число
str2Num proc
	push BX
	push SI
	pushf
	
	xor AX, AX
	xor BX, BX
	cld ; сброс DF в ноль.
	
	lodsb
	push AX ; для последующего определения знака
	
	cmp AL, '+'
	je convert
	
	cmp AL, '-'
	je convert
	
	dec SI

convert:
	lods byte ptr DS:[SI]
	
	sub AL, '0'
	cmp AL, 9d
	ja not_digit
	
	imul BX, 10d
	add BX, AX
	
	jmp convert
	
not_digit:
	mov AX, BX
; делаем число отрицательным.. или нет
	pop BX
	cmp BX, '-'
	jne return
	neg AX
	
return:	
	popf
	pop SI
	pop BX
	ret
str2Num endp

; Из числа делаем строку, которую впоследствии выводим
; Входные переменные:
; 	в AX - число
; 	в DI - буфер
; Выходные переменные:
; 	пусто
num2Str proc
	push BX
	push DI

; готовим буфер	
	xor DX, DX
	mov DL, byte ptr DS:[DI]
	inc DL
	add DI, DX
	mov BL, endstring
	mov byte ptr DS:[DI], BL
	
; проверяем на отрицательность
	shl AX, 1
	pushf ; нам важен флаг CF
	jnc begin
	
	not AX
	inc AX
	inc AX
	
begin:
	shr AX, 1
	mov BX, 0Ah ; наша разрядность
cycle:
	xor DX, DX
	div BX
	add DX, '0'
	dec DI
	mov byte ptr DS:[DI], DL
	test AX, AX
	jne cycle
	
	popf
	jnc print_result
	dec DI
	mov byte ptr DS:[DI], '-'
	
print_result:
	mov AX, DI
	call print
	
	pop DI
	pop BX
num2Str endp

theend:
	mov ah, 4ch
	int 21h
end start