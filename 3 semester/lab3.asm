;{-------------------------------------------------------------------------------------------------;
; ����䨪��� �।��饩 ���� "������� ������� 楫�� �ᥫ ��� �� ��㣠. � �뢮��� १����" ;
; encoding CP-866																				  ;
;-------------------------------------------------------------------------------------------------;}

.model small
.stack 100h
.386
.data
	strend		db		10, 13, '������ �������: ', '$'
	strer 		db		10, 13, '������ ����⥫�: ', '$'
	strout 		db		10, 13, '������ ��⭮�: ', '$'
	buffer		db		05h, 6 dup (?)
	endstring	db		'$'
	
.code
start:

	mov AX, @data
	mov DS, AX

; Main

delimoe:
; �뢮��� ��ப� "������ �������: "
	mov AX, offset strend
	call print

; ����砥� �������
	mov DI, offset buffer
	call getNumber
	
	test AX, AX
	je delimoe
	
	push AX

delitel:
; �뢮��� ��ப�, �� 㦥 � ����⥫�
	mov AX, offset strer
	call print

; ����砥� ᠬ ����⥫�
	mov DI, offset buffer
	call getNumber
	
	test AX, AX
	je delitel
	
	push AX
	
; �뢮� ��ப�: "������ ��⭮�: "
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
	
	inc DI ; ⥯��� DI 㪠�뢠�� �� ����� ����
	mov BL, byte ptr DS:[DI]
	inc DI ; DI ��⠭����� �� ��砫� ���祭��
	mov byte ptr [DI + BX], 00h
	
	mov SI, DI
	call str2Num
	
	pop DI
	popf
	pop BX
	pop DX
	ret
getNumber endp

; ��������� ��ப� � �᫮. ���ᨭ�, ��-��襬�
; �室�� ��६����:
; 	SI - ���� � ��ப�� ��� �������樨, ����稢��騩�� ���
; ��室�� ��६����:
; 	AX - ����祭��� �᫮
str2Num proc
	push BX
	push SI
	pushf
	
	xor AX, AX
	xor BX, BX
	cld ; ��� DF � ����.
	
	lodsb
	push AX ; ��� ��᫥���饣� ��।������ �����
	
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
; ������ �᫮ ����⥫��.. ��� ���
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

; �� �᫠ ������ ��ப�, ������ ���᫥��⢨� �뢮���
; �室�� ��६����:
; 	� AX - �᫮
; 	� DI - ����
; ��室�� ��६����:
; 	����
num2Str proc
	push BX
	push DI

; ��⮢�� ����	
	xor DX, DX
	mov DL, byte ptr DS:[DI]
	inc DL
	add DI, DX
	mov BL, endstring
	mov byte ptr DS:[DI], BL
	
; �஢��塞 �� ����⥫쭮���
	shl AX, 1
	pushf ; ��� ����� 䫠� CF
	jnc begin
	
	not AX
	inc AX
	inc AX
	
begin:
	shr AX, 1
	mov BX, 0Ah ; ��� ࠧ�來����
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