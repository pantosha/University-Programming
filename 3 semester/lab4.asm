; ------------------------------------------------------------------------------
; ����� ��ப�, �������� ���冷� ᫮� � �।�������
; (���� �뫠 ࠬ� => ࠬ� �뫠 ����),
; �뢥�� ����祭��� ��ப�
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------

.model small
.stack 100
.386
.data
	sHello 		db		'������ ��ப� �� ����� 255 ᨬ�����:', 0Ah, 0Dh, '$'
	buffer		db		0FFh, 0FFh dup (?)
	sByeBye		db		0Ah, 0Dh, '����� � ���⭮� ���浪�:', 0Ah, 0Dh
	outbuffer	db		0FFh dup (?)
.code
assume DS: @data, ES: @data
start:

	mov AX, @data
	mov DS, AX
	mov ES, AX

	lea DX, sHello 
	call print ; �뢮��� ��ப� � ���졮� ����� ��ப�)

	lea DX, buffer
	call read ; ���뢠�� ��ப�, ������ �㤥� ��ࠡ��뢠��

	call analyze ; �믮��塞 �᫮��� ��襣� �������

	lea DX, sByeBye ; � �뢮��� १����
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

; �襭�� ������� �室�
analyze proc
	xor CX, CX
	mov SI, offset outbuffer ; �ᯮ����⥫쭠� ��ப� "�㤠"
	lea DI, buffer + 1
	mov CL, byte ptr DS:[DI] ; ����� ��ப�
	test CL, CL ; ����� ��ப�
	je pend ; � ��릮�
	
	add DI, CX

	mov AL, ' '
skipspace:
	std
	repe scasb
	je pend ; ��室��, ���� ��ப� ��⮨� �� ����� �஡����
	
; ����� ��ப�
	mov BX, CX
	inc BX ; ⥯��� ����� ⥪�饣� ᫮�� ����� � BX
	repne scasb
	jne copy ; �ந������ ��릮�, �᫨ ��। ᫮��� �� �㤥� �஡���
	inc DI	; ��� �� ᫮���� ��������� ����室��� ��� ���������� ࠧ���� 
	inc CX
copy:
	sub BX, CX
	xchg BX, CX
	
; copy string
	cld
	xchg DI, SI
	push SI ; ��㤠 ���� �� ᫥���饬 横��
	inc SI
	rep movsb
	
; add space
	stosb
	;mov byte ptr DS:[DI], '$'
; � SI - ��ப� "�㤠"
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