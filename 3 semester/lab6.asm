; ------------------------------------------------------------------------------
; ��䨪� ��� DOS. �ᯮ��㥬 ������ �������.
; ------------------------------------------------------------------------------
; Codepage: OEM-866
; ------------------------------------------------------------------------------
LOCALS
.model small
.stack 100
.386
; ������
swap macro	dest, src
	mov AX, dest
	xchg AX, src
	mov dest, AX
endm
; ����
	colBlack		equ		00h
	colWhite		equ		0Fh
	colYellow		equ		00001110b
	colRed			equ		00000100b
	colRuby			equ		0Ch
	colBlue			equ		01h
; ���祭� �������
Line struc
	x_beg			dw		00h	; ��砫쭠� ���न��� X
	y_beg			dw		00h	; ��砫쭠� ���न��� Y
	x_end			dw		00h	; ����筠� ���न��� X
	y_end			dw		00h	; ����筠� ���न��� Y
	color			db		00h ; 梥�
ends

Circle struc
	x_center		dw		00h	; 業�� X
	y_center		dw		00h	; 業�� Y
	radius			dw		00h ; ࠤ��� ���㦭���
	col				db		00h ; 梥�
ends

.data
	number_line		dw		22h
	lines			Line	<05h, 64h, 30h, 40h, colWhite>
					Line	<30h, 40h, 0E0h, 40h, colWhite>	; ��� ࠪ���, ���孨�
					Line	<0DFh, 40h, 0F5h, 25h, colWhite>
					Line	<0F5h, 25h, 0C9h, 25h, colWhite>
					Line	<0C9h, 25h, 09Dh, 40h, colWhite>
					Line	<05h, 63h, 30h, 88h, colWhite>
					Line	<30h, 88h, 30h, 40h, colWhite>
					Line	<30h, 88h, 0E0h, 88h, colWhite>	; ��� ࠪ���, ������
					Line	<0DFh, 88h, 0F5h, 0A3h, colWhite> 
					Line	<0F5h, 0A3h, 0C9h, 0A3h, colWhite>	; ᮯ�⪠
					Line	<0C9h, 0A3h, 09Dh, 88h, colWhite>
					Line	<0E0h, 89h, 0E0h, 3Fh, colWhite>	; ������ ����⨭�
					Line	<0E0h, 40h, 130h, 2Fh, colRed>	; ���� �����
					Line	<130h, 2Fh, 100h, 45h, colRed>	; ���� �����
					Line	<100h, 45h, 135h, 50h, colRed>	; ���� �����
					Line	<135h, 50h, 0FBh, 62h, colRed>	; ���� �����
					Line	<0FBh, 62h, 12Fh, 74h, colRed>	; ���� �����
					Line	<12Fh, 74h, 103h, 7Dh, colRed>	; ���� �����
					Line	<103h, 7Dh, 136h, 90h, colRed>	; ���� �����
					Line	<138h, 92h, 0E1h, 88h, colRed>	; ���� �����
					Line	<0E0h, 49h, 113h, 53h, colRuby>	; �࠭���� �����
					Line	<113h, 53h, 0E1h, 60h, colRuby>	; �࠭���� �����
					Line	<0E1h, 60h, 110h, 70h, colRuby>	; �࠭���� �����
					Line	<110h, 70h, 0E1h, 7Bh, colRuby>	; �࠭���� �����
					Line	<98d, 94d, 94d, 90d, colWhite>	; ����� ��
					Line	<94d, 90d, 93d, 96d, colWhite>	; ����� ��
					Line	<102d, 94d, 106d, 90d, colWhite>	; �ࠢ�� ��
					Line	<106d, 90d, 107d, 96d, colWhite>	; �ࠢ�� ��
					Line	<99d, 103d, 88d, 100d, colWhite>	; ���� ��
					Line	<99d, 101d, 88d, 103d, colWhite>	; ���� ��
					Line	<101d, 103d, 112d, 100d, colWhite>	; �ࠢ� ��
					Line	<101d, 101d, 112d, 103d, colWhite>	; �ࠢ� ��
					Line	<100d, 103d, 100d, 106d, colRuby>	; ���
					Line	<98d, 104d, 103d, 104d, colRuby>	; ���
	number_circle	dw		09h
	circles			Circle	<9Fh, 20h, 0Ah, colYellow>
					Circle	<9Ch, 21h, 3h, colYellow>
					Circle	<0A3h, 1Dh, 2h, colYellow>
					Circle	<20d, 180d, 6h, colYellow>
					Circle	<100d, 100d, 18d, colWhite>
					Circle	<170d, 100d, 18d, colWhite>
					Circle	<100d, 100d, 7d, 06d> ; ��誠 ���
					Circle	<97d, 98d, 3d, 09h> ; ��࣠�� ���
					Circle	<103d, 98d, 3d, 09h> ; ��࣠�� ���
.data?
	movement_X		dw		?
	movement_Y		dw		?
	delta			dw		?
	delta_X			dw		?
	delta_Y			dw		?
	S_X				dw		?
	S_Y				dw		?
.code
	assume DS: DGROUP
start:
	mov AX, DGROUP
	mov DS, AX
	
	call SetGraphicMode

	lea SI, circles
	mov AX, type Circle
	mov CX, number_circle
draw_circles:
	call DrawCircle
	add SI, AX
	loop draw_circles
	
	lea SI, lines
	mov AX, type Line
	mov CX, number_line
draw_lines:
	call DrawLine
	add SI, AX
	loop draw_lines

	mov AH, 08h
	int 21h
	
	call SetTextMode
jmp exit
; ------------------------------------------------------------------------------
; ��ॢ�� DOS � ���. ०��
; ------------------------------------------------------------------------------
SetGraphicMode proc
; �室:
;	��祣�
; ��室:
;	��祣�
; ------------------------------------------------------------------------------
	push AX
	mov AX, 13h
	int 10h
	pop AX
	ret
endp

; ------------------------------------------------------------------------------
; ��ॢ�� DOS � ⥪�⮢� ०��
; ------------------------------------------------------------------------------
SetTextMode proc
; �室:
;	��祣�
; ��室:
;	��祣�
; ------------------------------------------------------------------------------
	push AX
	mov AX, 0003h
	int 10h
	pop AX
	ret
endp

; ------------------------------------------------------------------------------
; CharAddr. ���᫥��� 䨧��᪮�� ᬥ饭��
; ᨬ���� �� ������� ���न��⠬
; ------------------------------------------------------------------------------
CharAddr proc
; �室:
;	AX - ��ਧ��⠫쭠� ���न��� X
;	BX - ���⨪��쭠� ���न��� Y
; ��室:
;	DI - ᬥ饭�� ᨬ���� �� ������� ���न��⠬
; ------------------------------------------------------------------------------
	push AX BX DX
	xchg AX, BX
	mov DX, 320d
	mul DX
	add AX, BX
	mov DI, AX
; ����� ��� � ��࠭��� �������
	pop DX BX AX
	ret
endp

; ------------------------------------------------------------------------------
; WritePixel. ������ ���ᥫ� �� ������� ���न��⠬
; ------------------------------------------------------------------------------
WritePixel proc
; �室:
;	AX - ��ਧ��⠫쭠� ���न���
;	BX - ���⨪��쭠� ���न���
;	DL - 梥�
; ------------------------------------------------------------------------------
	push CX DI ES
; ����頥� � ES ᥣ���� ���������
	push 0A000h
	pop ES
; ����塞 ������ ᬥ饭�� ᨬ����
	call CharAddr
 ; �뢮��� ᨬ��� �� �࠭��� ��࠭���
	mov ES:[DI], DL
	pop ES DI CX
	ret
endp

; ------------------------------------------------------------------------------
; ��ᮢ���� �����
; ------------------------------------------------------------------------------
DrawLine proc
; �室:
;	SI - 㪠��⥫� �� �������� Line
	push AX CX
	mov DL, [SI].color
; ��諨 ࠧ���� �� X
	mov AX, [SI].x_beg
	sub AX, [SI].x_end
; ��諨 ࠧ���� �� Y
	mov BX, [SI].y_beg
	sub BX, [SI].y_end

	mov s_X, -01h
	test AX, AX
	jns @@abs_y
	neg AX
	mov s_X, 01h
@@abs_y:
	mov s_Y, -01h	; ������⭠� ��६�����
	test BX, BX
	jns @@is_vertical
	neg BX
	mov s_Y, 01h
@@is_vertical:
; �஢�ઠ �� ���⨪��쭮���
; � �ᮢ���� ����� � ��砥 㤠�
	test AX, AX
	jne @@is_horizont
	mov CX, BX
	mov AX, [SI].x_beg
	mov BX, [SI].y_beg
	cmp BX, [SI].y_end
	jbe @@for_vertical
	mov BX, [SI].y_end
; ��㥬 ���⨪���
@@for_vertical:
	call WritePixel
	inc BX
	loop @@for_vertical
	jmp @@exit
; �஢�ઠ �� ��ਧ��⠫쭮���
; � �ᮢ���� ����� � ��砥 㤠�
@@is_horizont:
	test BX, BX
	jne @@general_provision
	mov CX, AX
	mov BX, [SI].y_beg
; ����頥� � AX ���������� ���न���� X
	mov AX, [SI].x_beg
	cmp AX, [SI].x_end
	jbe @@for_horizont
	mov AX, [SI].x_end
; ��㥬 ��ਧ��⠫�
@@for_horizont:
	call WritePixel
	inc AX
	loop @@for_horizont
	jmp @@exit

@@general_provision:
; �⥫��� ��� ����, � ����稫��� ��� � ���ન
; ����� ��砫�� ��ࠬ���� ��६�����
	mov movement_X, 00h
	mov movement_Y, 00h
	mov delta_x, AX
	mov delta_Y, BX
	cmp AX, BX
	jae @@after_delta
	mov AX, BX
@@after_delta:
	mov delta, AX	; delta - ��६�����, �⢥���� �� 䨣 ����� ��
; ����㦠�� ��砫�� ���न����
	mov AX, [SI].x_beg
	mov BX, [SI].y_beg
@@loop:
; ���� ᫥���饩 �窨
; X
	mov CX, movement_X
	sub CX, delta_X
	mov movement_X, CX
	
	test CX, CX
	jns @@for_y
	add CX, delta
	mov movement_X, CX
	add AX, s_X

@@for_y:
	mov CX, movement_Y
	sub CX, delta_Y
	mov movement_Y, CX
	
	test CX, CX
	jns @@draw
	add CX, delta
	mov movement_Y, CX
	add BX, s_Y
@@draw:
	call WritePixel

	cmp AX, [SI].x_end
	jne @@loop
	cmp BX, [SI].y_end
	jne @@loop
@@exit:
	pop CX AX
	ret
endp

; --------------------------------------------------------------------------------------------------
; Draws 4 symmetrical circle plots
; --------------------------------------------------------------------------------------------------
Circle_plot proc
; �室:
;	SI - 㪠��⥫� �� �������� ⨯� Circle
	mov DL, [SI].col
	mov AX, [SI].x_center
	add AX, S_X
	mov BX, [SI].y_center
	add BX, S_Y
	call WritePixel
	sub BX, S_Y
	sub BX, S_Y
	call WritePixel
	sub AX, S_X
	sub AX, S_X
	call WritePixel
	add BX, S_Y
	add BX, S_Y
	call WritePixel
	ret
endp
; -----------------------------------------------------------------------------------------------------
; Draw Circle with center on (X0, Y0) and fixed Radius
; -----------------------------------------------------------------------------------------------------
DrawCircle proc	
	push AX CX
	xor BX, BX
	mov movement_X, BX
	mov S_X, BX
	mov BX, [SI].radius
	mov S_Y, BX ; � y - ࠤ���
	mov AX, BX
	shl AX, 01h
	sub AX, 3 ; ��竨 �� ࠤ��� 3
	neg AX ; ᤥ���� ����⥫쭮� �᫮
	mov movement_X, AX ; �����⨫� �㤠-�
Circle_while_loop:
	mov BX, S_X
	cmp BX, S_Y
	jnb Circle_end
	call Circle_plot
; �����﫨 ���⠬� x � y
	swap S_X, S_Y
	call Circle_plot
	swap S_X, S_Y
	mov AX, movement_X
	test AX, AX
	jns Circle_else
	mov BX, S_X
	shl BX, 02h
	add AX, BX
	add AX, 6
	mov movement_X, AX
	jmp Circle_endif
Circle_else:
	mov AX, S_Y
	dec AX
	mov S_Y, AX
	mov AX, S_X
	sub AX, S_Y
	shl AX, 02h
	mov BX, AX
	mov AX, movement_X
	add AX, BX
	add AX, 10
	mov movement_X, AX
Circle_endif:
	mov AX, S_X
	inc AX
	mov S_X, AX
	jmp Circle_while_loop
Circle_end:
	mov AX, S_X
	cmp AX, S_Y
	jne Circle_exit
	call Circle_plot
Circle_exit:
	pop CX AX
	ret
endp

exit:
	mov AH, 4Ch
	int 21h
end start