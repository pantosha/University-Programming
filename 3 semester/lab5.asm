; ------------------------------------------------------------------------------
; Открыть матрицу 
; Нахождение в столбце 3 наибольших элемента и смена их местами
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------
LOCALS
.model small
.stack 100
.386
.data
bEl struc
	value		db		00h
	position	db		00h
ends
	handle		dw		(?)
	
	lenbuf		=		3
	tempbuffer	bEl		lenbuf dup (<00h, 00h>)
	
	row 		db		00h
	column		db		00h
	matrix		db		0FFh, 0FFh dup (?)
	buffer		db		0FFh, 0FFh dup (?)

	sFilename	db		'matrix.txt', 0
	sResult		db		'result.txt', 0
	sOpen 		db		'Открытие файла:', 0Dh, 0Ah, '$'
	sTransform 	db		0Dh, 0Ah, 'Преобразование матрицы:', 0Dh, 0Ah, '$'
	sSave		db		0Dh, 0Ah, 'Файл сохранён...', '$'
	sError		db		'Произошла ошибка.', '$'
.code
start:
	mov AX, @data
	mov DS, AX
	mov ES, AX
; вывод строки об открытии файла	
	lea DX, sOpen
	call print
; непосредственно открытие файла
	lea DX, sFilename
	call fopen
	jc exit
; создание матрицы в памяти
	mov BX, [handle]
	call getMatrix
	test AX, AX
	je exit
; закрытие файла	
	mov BX, [handle]
	call fclose
; преобразовываем для печати
	call matrixtransform
; печатаем	
	call printmatrix
; вывод строки о преобразовании
	lea DX, sTransform
	call print
; процедура смены местами ячеек	
	lea SI, matrix
	xor CX, CX
	mov CL, column
run_at_column:
	call work
	call zerobuf
	inc SI
	loop run_at_column
; конец процедуры смены местами ячеек	
	call matrixtransform
	call printmatrix
; создаём файл
	lea DX, sResult
	call fcreate
; записываем инфу
	mov BX, AX
	call savematrix
	call fclose
	jmp exit
; ------------------------------------------------------------------------------
; Создаём файл
; ------------------------------------------------------------------------------
proc fcreate
; Вход:
;	DX - указатель на имя файла
; Выход:
;	AX - ошибка или handle в зависимости от флага CF
; ------------------------------------------------------------------------------
	mov AH, 3Ch
	xor CX, CX
    int 21h
	jc @@error_fcreate
	mov [handle], AX
	jmp @@exit_fcreate
@@error_fcreate:	
	call error_msg	;Иначе вывод сообщения об ошибке
@@exit_fcreate:
	ret
endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
	
; ------------------------------------------------------------------------------
; Обнуляем буфер
; ------------------------------------------------------------------------------
proc zerobuf
	push CX DI
	xor AX, AX
	mov CX, lenbuf
	lea DI, tempbuffer
	rep stosw
	pop DI CX
	ret
endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Открытие файла для чтения
; ------------------------------------------------------------------------------
fopen proc
; Вход:
;	DX - указатель на имя файла
; Выход:
;	AX - ошибка или handle в зависимости от флага CF
; ------------------------------------------------------------------------------
	mov AH, 3Dh	; функция DOS 3Dh (открытие файла)
    xor AL, AL	; только чтение
    int 21h
	jc error_fopen
	mov [handle], AX
	jmp exit_fopen
error_fopen:	
	call error_msg	;Иначе вывод сообщения об ошибке
exit_fopen:
	ret
fopen endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Закрытие файла
; ------------------------------------------------------------------------------
fclose proc
; Вход:
;	BX - указатель на имя файла
	mov AH, 3Eh
	int 21h
	; тут должна быть обработка ошибок
	ret
fclose endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Получение слова из строки
; ------------------------------------------------------------------------------
getNumber proc
; Вход:
; 	SI - строка
;	DX - длина строки
; Выход:
;	AX - очередное число матрицы
;	DX - длина оставшейся строки
;	SI - оставшаяся строка
	push BX
	push CX	
	mov CX, DX
	test CX, CX
	stc
	je exit_getNumber
	cld ; сброс DF в ноль.
skip:
	lodsb
	sub AL, '0'
	cmp AL, 9d
	jna convert
	loop skip

	stc
	jmp exit_getNumber
convert:
	mov BX, AX
	dec CX
	test CX, CX

	stc
	je exit_getNumber
	lodsb
	dec CX
	sub AL, '0'
	cmp AL, 9d
	ja not_digit
	imul BX, 10d
	add BX, AX
not_digit:
	mov AX, BX
exit_getNumber:
	mov DX, CX
	pop CX
	pop BX
	ret
getNumber endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Чтение матрицы из файла
; ------------------------------------------------------------------------------
getMatrix proc
; Вход:
;	BX - указатель на имя файла
; Выход:
;	AX - кол-во ячеек массива или 00 в случае ошибки
; ------------------------------------------------------------------------------
	push BX
; Считываем файл в буфер
	lea DX, buffer
	inc DX
	xor CX, CX
	mov CL, [buffer]
	mov AH, 3Fh
	int 21h
	jc error_getMatrix
; там что-то остаётся в AX, надо бы проверить
	
; получение строк
	mov SI, DX
	mov DX, AX
	call getNumber
	mov byte ptr DS:[row], AL
; получение столбцов
	call getNumber
	mov byte ptr DS:[column], AL
	mul row
	mov BX, AX
	mov CX, AX
	lea DI, matrix
initMatrix:
	call getNumber
	jc error_getMatrix
	stosb
	loop initMatrix

	mov AX, BX
	jmp exit_getMatrix
error_getMatrix:
	call error_msg
	xor AX, AX
exit_getMatrix:
	pop BX
	ret
getMatrix endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Print string
; ------------------------------------------------------------------------------
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
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Распечатать матрицу
; ------------------------------------------------------------------------------
printmatrix proc
	push DX
	lea DX, buffer
	inc DX
	call print
	pop DX
	ret
endp

; ------------------------------------------------------------------------------
; Сохранить матрицу в файл
; ------------------------------------------------------------------------------
savematrix proc
; Вход:
;	BX - handle
; Выход:
;	хз, может, флаг CF
; ------------------------------------------------------------------------------
	push CX BX SI
	
	xor CX, CX
	lea SI, buffer
	mov CL, byte ptr DS:[SI]
	mov DX, SI
	inc DX
	mov AH, 40h
	int 21h
	jc @@error_savematrix
	lea DX, sSave
	call print	; выводим сообщение об успехе
	jmp @@exit
@@error_savematrix:
	call error_msg	;Иначе, вывод сообщения об ошибке
@@exit:
	pop SI BX CX
	ret
endp

; ------------------------------------------------------------------------------
; Преобразовываем матрицу для вывода
; ------------------------------------------------------------------------------
proc matrixtransform
; Вход:
;	ничего
; Выход:
;	AX - длина текста
; ------------------------------------------------------------------------------
	lea DI, buffer
	push DI
	inc DI
	lea SI, matrix
	mov DL, row
	cld
@@run_at_row:
	xor CX, CX
	mov CL, column
	dec CX
	
	lodsb
	call DecToStr	; осталось только написать
	stosw
@@run_at_column:
	mov AL, ' '
	stosb
	lodsb
	call DecToStr	; осталось только написать
	stosw
	loop @@run_at_column

	dec DL
	test DL, DL
	je @@length
		
	mov AX, 0A0Dh
	stosw
	jmp @@run_at_row

@@length:
; считаем длину получившегося текста
	mov byte ptr [DI], '$'
	pop AX
	sub DI, AX
	xchg AX, DI
	dec AX
	stosb
	
	ret
endp

DecToStr proc
; !!! Только для этой лабы
; Вход:
;	AL - число
; Выход:
;	AX - число, что и на входе, только символами
; ------------------------------------------------------------------------------
	push BX DX
	xor AH, AH
	mov BX, 10d ; основание системы счисления
	xor DX, DX
	div BX
	add DX, '0'
	mov AH, DL
	add AL, '0' 
	pop DX BX
	ret
endp

; ------------------------------------------------------------------------------
; Основная процедура
; ------------------------------------------------------------------------------
proc work
; Вход:
;	SI - на столбец
; Выход:
;	ничего
; ------------------------------------------------------------------------------
	push AX BX CX SI DI
	push SI
	
	xor CX, CX
	mov CL, byte ptr DS:[row]
	
	xor BX, BX
	mov BL, byte ptr DS:[column]
; вдруг не надо сложных алгоритмов и перемещений?
	cmp CX, lenbuf
	ja @@more_than_three
	cmp CX, 01h
	jbe @@exit
; если кол-во строк >1 и =<3
	dec CX
	mov AL, byte ptr [SI]
	;push SI
@@cycle_small_rotate:
	add SI, BX
	xchg AL, byte ptr [SI]
	loop @@cycle_small_rotate
	pop SI
	mov byte ptr [SI], AL
	jmp @@exit
; находим в столбце 3 максимальных элемента и сохраняем их в буфере
@@more_than_three:
	xor AX, AX
@@for_column:
	mov CX, lenbuf
	mov AL, byte ptr DS:[SI]	; загружаем очередное значение из матрицы
	push AX
	lea DI, tempbuffer
@@comparator:
	cmp AL, byte ptr DS:[DI]
	jbe @@next_number
	xchg AX, word ptr [DI]
@@next_number:
	inc DI
	inc DI
	loop @@comparator

	add SI, BX
	pop AX
	inc AH
	cmp AH, row
	jb @@for_column
; конец more_than_three
; сортируем tempbuffer по порядку номеров в столбце
	mov CX, 02h
for_i:
	lea SI, tempbuffer
	mov DI, CX
what_else:
	mov AX, word ptr DS:[SI]
	cmp AH, byte ptr DS:[SI + 3]
	ja no_swap ; jb
	xchg AX, [SI + 2]
	mov word ptr DS:[SI], AX
no_swap:
	inc SI
	inc SI
	loop what_else
	
	mov CX, DI
	loop for_i
; меняем местами значения
	mov CX, lenbuf - 1
	lea SI, tempbuffer
	inc SI
	lodsb
	
@@cycle_rotate:
	inc SI
	xchg AL, byte ptr DS:[SI]
	inc SI
	loop @@cycle_rotate
	lea SI, tempbuffer
	mov byte ptr [SI + 1], AL
; записываем их обратно в матрицу
	mov CX, lenbuf
	pop BX
@@cycle_write:
	mov DI, BX
	lodsw
	push AX
	xchg AH, AL
	mul [column]
	add DI, AX
	pop AX
	mov byte ptr [DI], AL
	loop @@cycle_write
@@exit:
	pop DI SI CX BX AX
	ret
endp

error_msg proc
; Вход:
;	AX - код ошибки
	pushf
; ---- Недописано ----
    mov AH, 9
    lea DX, sError
    int 21h                 ;Вывод сообщения об ошибке
	popf
    ret
endp

exit:
	mov ah, 4ch
	int 21h
end start