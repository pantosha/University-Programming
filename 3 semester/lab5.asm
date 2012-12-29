; ------------------------------------------------------------------------------
; ������ ������ 
; ��宦����� � �⮫�� 3 ��������� ����� � ᬥ�� �� ���⠬�
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
	sOpen 		db		'����⨥ 䠩��:', 0Dh, 0Ah, '$'
	sTransform 	db		0Dh, 0Ah, '�८�ࠧ������ ������:', 0Dh, 0Ah, '$'
	sSave		db		0Dh, 0Ah, '���� ��࠭�...', '$'
	sError		db		'�ந��諠 �訡��.', '$'
.code
start:
	mov AX, @data
	mov DS, AX
	mov ES, AX
; �뢮� ��ப� �� ����⨨ 䠩��	
	lea DX, sOpen
	call print
; �����।�⢥��� ����⨥ 䠩��
	lea DX, sFilename
	call fopen
	jc exit
; ᮧ����� ������ � �����
	mov BX, [handle]
	call getMatrix
	test AX, AX
	je exit
; �����⨥ 䠩��	
	mov BX, [handle]
	call fclose
; �८�ࠧ��뢠�� ��� ����
	call matrixtransform
; ���⠥�	
	call printmatrix
; �뢮� ��ப� � �८�ࠧ������
	lea DX, sTransform
	call print
; ��楤�� ᬥ�� ���⠬� �祥�	
	lea SI, matrix
	xor CX, CX
	mov CL, column
run_at_column:
	call work
	call zerobuf
	inc SI
	loop run_at_column
; ����� ��楤��� ᬥ�� ���⠬� �祥�	
	call matrixtransform
	call printmatrix
; ᮧ��� 䠩�
	lea DX, sResult
	call fcreate
; �����뢠�� ����
	mov BX, AX
	call savematrix
	call fclose
	jmp exit
; ------------------------------------------------------------------------------
; ������ 䠩�
; ------------------------------------------------------------------------------
proc fcreate
; �室:
;	DX - 㪠��⥫� �� ��� 䠩��
; ��室:
;	AX - �訡�� ��� handle � ����ᨬ��� �� 䫠�� CF
; ------------------------------------------------------------------------------
	mov AH, 3Ch
	xor CX, CX
    int 21h
	jc @@error_fcreate
	mov [handle], AX
	jmp @@exit_fcreate
@@error_fcreate:	
	call error_msg	;���� �뢮� ᮮ�饭�� �� �訡��
@@exit_fcreate:
	ret
endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
	
; ------------------------------------------------------------------------------
; ����塞 ����
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
; ����⨥ 䠩�� ��� �⥭��
; ------------------------------------------------------------------------------
fopen proc
; �室:
;	DX - 㪠��⥫� �� ��� 䠩��
; ��室:
;	AX - �訡�� ��� handle � ����ᨬ��� �� 䫠�� CF
; ------------------------------------------------------------------------------
	mov AH, 3Dh	; �㭪�� DOS 3Dh (����⨥ 䠩��)
    xor AL, AL	; ⮫쪮 �⥭��
    int 21h
	jc error_fopen
	mov [handle], AX
	jmp exit_fopen
error_fopen:	
	call error_msg	;���� �뢮� ᮮ�饭�� �� �訡��
exit_fopen:
	ret
fopen endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; �����⨥ 䠩��
; ------------------------------------------------------------------------------
fclose proc
; �室:
;	BX - 㪠��⥫� �� ��� 䠩��
	mov AH, 3Eh
	int 21h
	; ��� ������ ���� ��ࠡ�⪠ �訡��
	ret
fclose endp
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; ����祭�� ᫮�� �� ��ப�
; ------------------------------------------------------------------------------
getNumber proc
; �室:
; 	SI - ��ப�
;	DX - ����� ��ப�
; ��室:
;	AX - ��।��� �᫮ ������
;	DX - ����� ��⠢襩�� ��ப�
;	SI - ��⠢���� ��ப�
	push BX
	push CX	
	mov CX, DX
	test CX, CX
	stc
	je exit_getNumber
	cld ; ��� DF � ����.
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
; �⥭�� ������ �� 䠩��
; ------------------------------------------------------------------------------
getMatrix proc
; �室:
;	BX - 㪠��⥫� �� ��� 䠩��
; ��室:
;	AX - ���-�� �祥� ���ᨢ� ��� 00 � ��砥 �訡��
; ------------------------------------------------------------------------------
	push BX
; ���뢠�� 䠩� � ����
	lea DX, buffer
	inc DX
	xor CX, CX
	mov CL, [buffer]
	mov AH, 3Fh
	int 21h
	jc error_getMatrix
; ⠬ ��-� ������� � AX, ���� �� �஢����
	
; ����祭�� ��ப
	mov SI, DX
	mov DX, AX
	call getNumber
	mov byte ptr DS:[row], AL
; ����祭�� �⮫�殢
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
; ��ᯥ���� ������
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
; ���࠭��� ������ � 䠩�
; ------------------------------------------------------------------------------
savematrix proc
; �室:
;	BX - handle
; ��室:
;	�, �����, 䫠� CF
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
	call print	; �뢮��� ᮮ�饭�� �� �ᯥ�
	jmp @@exit
@@error_savematrix:
	call error_msg	;����, �뢮� ᮮ�饭�� �� �訡��
@@exit:
	pop SI BX CX
	ret
endp

; ------------------------------------------------------------------------------
; �८�ࠧ��뢠�� ������ ��� �뢮��
; ------------------------------------------------------------------------------
proc matrixtransform
; �室:
;	��祣�
; ��室:
;	AX - ����� ⥪��
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
	call DecToStr	; ��⠫��� ⮫쪮 �������
	stosw
@@run_at_column:
	mov AL, ' '
	stosb
	lodsb
	call DecToStr	; ��⠫��� ⮫쪮 �������
	stosw
	loop @@run_at_column

	dec DL
	test DL, DL
	je @@length
		
	mov AX, 0A0Dh
	stosw
	jmp @@run_at_row

@@length:
; ��⠥� ����� ����稢襣��� ⥪��
	mov byte ptr [DI], '$'
	pop AX
	sub DI, AX
	xchg AX, DI
	dec AX
	stosb
	
	ret
endp

DecToStr proc
; !!! ���쪮 ��� �⮩ ����
; �室:
;	AL - �᫮
; ��室:
;	AX - �᫮, �� � �� �室�, ⮫쪮 ᨬ������
; ------------------------------------------------------------------------------
	push BX DX
	xor AH, AH
	mov BX, 10d ; �᭮����� ��⥬� ��᫥���
	xor DX, DX
	div BX
	add DX, '0'
	mov AH, DL
	add AL, '0' 
	pop DX BX
	ret
endp

; ------------------------------------------------------------------------------
; �᭮���� ��楤��
; ------------------------------------------------------------------------------
proc work
; �室:
;	SI - �� �⮫���
; ��室:
;	��祣�
; ------------------------------------------------------------------------------
	push AX BX CX SI DI
	push SI
	
	xor CX, CX
	mov CL, byte ptr DS:[row]
	
	xor BX, BX
	mov BL, byte ptr DS:[column]
; ���� �� ���� ᫮���� �����⬮� � ��६�饭��?
	cmp CX, lenbuf
	ja @@more_than_three
	cmp CX, 01h
	jbe @@exit
; �᫨ ���-�� ��ப >1 � =<3
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
; ��室�� � �⮫�� 3 ���ᨬ����� ����� � ��࠭塞 �� � ����
@@more_than_three:
	xor AX, AX
@@for_column:
	mov CX, lenbuf
	mov AL, byte ptr DS:[SI]	; ����㦠�� ��।��� ���祭�� �� ������
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
; ����� more_than_three
; ����㥬 tempbuffer �� ���浪� ����஢ � �⮫��
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
; ���塞 ���⠬� ���祭��
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
; �����뢠�� �� ���⭮ � ������
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
; �室:
;	AX - ��� �訡��
	pushf
; ---- ������ᠭ� ----
    mov AH, 9
    lea DX, sError
    int 21h                 ;�뢮� ᮮ�饭�� �� �訡��
	popf
    ret
endp

exit:
	mov ah, 4ch
	int 21h
end start