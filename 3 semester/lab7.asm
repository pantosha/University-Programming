; ------------------------------------------------------------------------------
; ������ ����� ��஫�. ��४�� AH 0Ah int 21h, ���� �������� �����窠��
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
;�뢮� ��ப� �� �࠭.
;�� �室� - �����䨪��� ��砫� �뢮����� ��ப�.
;��ப� ������ �����稢����� ᨬ����� '$'.
;�� ��室� - ᮮ�饭�� �� �࠭�.
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
; �室:
;	AH - 0Ah
;	AL - ��ଠ��� ���� (AL<>0) ��� � ��񧤮窠�� (AL=0)
;	DX - 㪠��⥫� �� ����
; ------------------------------------------------------------------------------
	cmp AH, 0Ah
	jne @@dos_interrupt
	test AL, AL
	jne @@dos_interrupt
; �����।�⢥��� ᠬ� ����⢮:
	push AX BX DX ES
; ES = DS
	push DS
	pop ES
	mov DI, DX
; 㧭�� ����� ����
	xor CX, CX
	mov CL, byte ptr [DI]
	test CL, CL
	je @@return
	mov BX, CX
	inc DI
	inc DI
	cld
@@cycle:
; ��⮢�� ���뢠���
	mov AH, 08h
	int 21h
@@Backspace:
	cmp AL, kBackspace
	jne @@save_sym
	cmp CX, BX
	jae @@cycle
; ������� �����:
	mov AH, 02h
	mov DL, AL
	int 21h
	mov DL, ' '
	int 21h
	mov DL, kBackspace
	int 21h
; 㤠���� ᨬ���
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
; ��ᮢ᪮� ���뢠���
@@dos_interrupt:
	jmp CS:[old_interrupt]
endp

Initialize proc
; �⥭�� ���� �ணࠬ�� ��ࠡ��稪� ���뢠���
	push AX ES
	mov AX, 3521h
	int 21h
	mov word ptr CS:[old_interrupt] + 2, ES
	mov word ptr CS:[old_interrupt], BX
	
; ��⠭���� ������ ��ࠡ��稪� ���뢠���
	mov AX, 2521h
	mov DX, offset Interrupt
	int 21h
	pop ES AX
	ret
endp

isInitialize proc
; �⥭�� ���� �ணࠬ�� ��ࠡ��稪� ���뢠���
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
; ����稫� ���� �뭥 ��⠭��������� ���뢠���
	mov AX, 3521h
	int 21h
; ��⠭����� ��஥ ���뢠���
	mov AX, 2521h
	mov DX, word ptr ES:[old_interrupt] + 2
	mov DS, DX
	mov DX, word ptr ES:[old_interrupt]
	int 21h

	pop ES DS DX AX
	ret
endp
Check_Up proc
	mov SI, 80h	;SI=ᬥ饭�� ��������� ��ப�.
	lodsb	;����稬 ���-�� ᨬ�����.
	cmp AL, 25d
	ja @@no_string ;AL > 25? - �� ���� @@no_string
	test AL, AL     ;��� ��������� ��ப�?
	jz @@no_string ;�� ���� No_string
	inc SI
	mov DI, SI
; �饬 ᨬ��� ������� ('/')
	xor CX, CX
	mov CL, AL
@@next_char:
	mov AL, '/'
	repne scasb	; �饬
	test CX, CX	; �� ��諨?
	je @@no_string	; �訡��
	mov DL, byte ptr [DI]
	mov AX, 6520h
	int 21H	; �ਢ������ ᨬ���� � ���孥�� ॣ�����
@@Init:
	cmp DL, 'I'
	jne @@Deinit
; ��⠭����� �� ��ࠡ��稪
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
	sAlreadyInstall		db		0Dh, 0Ah, '��ࠡ��稪 ���뢠��� 㦥 ��⠭�����.', '$'
	sGoodInstall		db		0Dh, 0Ah, '��ࠡ��稪 �ᯥ譮 ��⠭�����.', '$'
	sGoodRemove			db		0Dh, 0Ah, '��ࠡ��稪 �ᯥ譮 㤠��.', '$'
	sAlreadyRemove		db		0Dh, 0Ah, '��ࠡ��稪 �� ��⠭�����.', '$'
	sError_cmdline		db		0Dh, 0Ah, '�訡�� � ��������� ��ப�.', '$'
end start