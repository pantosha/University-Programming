; ------------------------------------------------------------------------------
; аналог ввода пароля. Перекрыв AH 0Ah int 21h, ввод заменить звздочками
; PAN
; Change encoding to OEM866 (CP866)!
; ------------------------------------------------------------------------------
LOCALS
.model tiny
.386
; ------------------------------------------------------------------------------
; Macros
; ------------------------------------------------------------------------------
OutStr	macro	str
;Вывод строки на экран.
;На входе - идентификатор начала выводимой строки.
;Строка должна заканчиваться символом '$'.
;На выходе - сообщение на экране.
	push AX DX
	mov	ah,09h
	lea	dx,str
	int	21h
	pop DX AX
endm
; ------------------------------------------------------------------------------
	install			equ		'I'
	delete			equ		'D'
	kBackspace		equ		08h
	kEnter			equ		0Dh
	magicword		equ		4343h
	sym_pass		equ		'*'
.code
org 80h
	cmd_len			db		?
	cmd_line		db		?
org 100h
start:
	jmp	Check_Up
	
	random_number		dw		magicword
	old_interrupt		dd		(00h)
	
Interrupt proc
; Вход:
;	AH - 0Ah
;	AL - нормальный ввод (AL<>0) или со звёздочками (AL=0)
;	DX - указатель на буфер
; ------------------------------------------------------------------------------
	cmp AH, 0Ah
	jne @@dos_interrupt
	test AL, AL
	jne @@dos_interrupt
; непосредственно само действо:
	push AX BX DX ES
; ES = DS
	push DS
	pop ES
	mov DI, DX
; узнаём длину буфера
	xor CX, CX
	mov CL, byte ptr [DI]
	test CL, CL
	je @@return
	mov BX, CX
	inc DI
	inc DI
	cld
@@cycle:
; готовим прерывание
	mov AH, 08h
	int 21h
@@Backspace:
	cmp AL, kBackspace
	jne @@save_sym
	cmp CX, BX
	jae @@cycle
; написать макрос:
	mov AH, 02h
	mov DL, AL
	int 21h
	mov DL, ' '
	int 21h
	mov DL, kBackspace
	int 21h
; удалили символ
	dec DI
	inc CX
	jmp @@cycle
@@save_sym:
	test CX, CX
	je @@cycle
	stosb
@@Enter:
	cmp AL, kEnter
	je @@out_of_cycle
	mov AH, 02h
	mov DL, sym_pass
	int 21h
	dec CX
	jmp @@cycle
@@out_of_cycle:
	sub BX, CX
	sub DI, BX
	dec DI
	mov byte ptr [DI] - 1, BL
@@return:
	pop AX BX DX ES
	iret
; досовское прерывание
@@dos_interrupt:
	jmp CS:[old_interrupt]
endp

Initialize proc
; Чтение адреса программы обработчика прерывания
	push AX ES
	mov AX, 3521h
	int 21h
	mov word ptr CS:[old_interrupt] + 2, ES
	mov word ptr CS:[old_interrupt], BX
	
; Установка нового обработчика прерывания
	mov AX, 2521h
	mov DX, offset Interrupt
	int 21h
	pop ES AX
	ret
endp

isInitialize proc
; Чтение адреса программы обработчика прерывания
	push AX ES
	mov AX, 3521h
	int 21h
	cmp word ptr ES:[random_number], magicword
	pop ES AX
	jne @@willbecontinued
	OutStr sAlreadyInstall
	stc
	ret
@@willbecontinued:
	OutStr sAlreadyRemove
	clc
	ret
endp
	
Deinitialize proc
	push AX DX DS ES
; получили адрес ныне установленного прерывания
	mov AX, 3521h
	int 21h
; установили старое прерывание
	mov AX, 2521h
	mov DX, word ptr ES:[old_interrupt] + 2
	mov DS, DX
	mov DX, word ptr ES:[old_interrupt]
	int 21h

	pop ES DS DX AX
	ret
endp
Check_Up proc
	mov SI, 80h	;SI=смещение командной строки.
	lodsb	;Получим кол-во символов.
	cmp AL, 25d
	ja @@no_string ;AL > 25? - на метку @@no_string
	test AL, AL     ;Нет командной строки?
	jz @@no_string ;На метку No_string
	inc SI
	mov DI, SI
; ищем символ команды ('/')
	xor CX, CX
	mov CL, AL
@@next_char:
	mov AL, '/'
	repne scasb	; ищем
	test CX, CX	; не нашли?
	je @@no_string	; ошибка
	mov DL, byte ptr [DI]
	mov AX, 6520h
	int 21H	; приведение символа к верхнему регистру
@@Init:
	cmp DL, 'I'
	jne @@Deinit
; установлен ли обработчик
	call isInitialize
	jc @@next_char
	call Initialize
	OutStr sGoodInstall
	mov DX, offset Initialize
	int 27h
@@Deinit:
	cmp DL, 'D'
	jne @@next_char
	call isInitialize
	jnc @@next_char
	call Deinitialize
	OutStr sGoodRemove
	jmp @@exit
@@no_string:
	mov DX, offset sError_cmdline
	mov AH, 09h
	int 21h
@@exit:
	mov DX, offset sError_cmdline
	mov AX, 0A00h
	int 21h
	mov AH, 4Ch
	int 21h
endp
	sAlreadyInstall		db		0Dh, 0Ah, 'Обработчик прерывания уже установлен.', '$'
	sGoodInstall		db		0Dh, 0Ah, 'Обработчик успешно установлен.', '$'
	sGoodRemove			db		0Dh, 0Ah, 'Обработчик успешно удалён.', '$'
	sAlreadyRemove		db		0Dh, 0Ah, 'Обработчик не установлен.', '$'
	sError_cmdline		db		0Dh, 0Ah, 'Ошибка в командной строке.', '$'
end start