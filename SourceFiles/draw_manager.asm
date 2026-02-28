; draw_manager.asm
; Contains methods for drawing on the terminal
; Learnt how to use multiple files with this Stack Overflow post
; https://stackoverflow.com/questions/62618027/how-to-write-and-combine-multiple-source-files-for-a-project-in-masm

INCLUDE Irvine32.inc

.data
dashedLine BYTE 120 DUP("-"), 0		; as long as the default window opening size

PumpkinBuffer BYTE 20, 11			; width and height of the ascii art in buffer 
	BYTE "           -.       ", 0
	BYTE "         -@%        ", 0
	BYTE "         =@#        ", 0
	BYTE "   =@@@@@**@@@@@#   ", 0
	BYTE "  %@@#*@@@@@@#*%@@  ", 0
	BYTE " @@@+   -@@*   .@@@ ", 0
	BYTE " @@@@@@@@@@@@@@@@@@ ", 0
	BYTE " %@@@@@@@-.#@@@@@@@ ", 0
	BYTE "  %@@@+-#%%%+:@@@@  ", 0
	BYTE "   *@@@*    -@@@@   ", 0
	BYTE "      ........      ", 0

.code
; ------------------------------
Draw PROC USES ebx ecx esi
; Takes no parameters
; Draws a pumpkin on the screen
; ------------------------------
	mov ebx, 0
	mov bl, PumpkinBuffer[0]		; store the width
	inc ebx							; account for null termination
	mov ecx, 0
	mov cl, PumpkinBuffer[1]		; store the height (for the loop)
	mov esi, 0
	mov edx, OFFSET PumpkinBuffer	; point to buffer
	add edx, 2
	L1:
		call WriteString
		call Crlf
		add edx, ebx				; skips to the next line for printing
		loop L1
	ret
Draw ENDP

; ------------------------------
ResetScreen PROC USES edx
; Does not take any parameters
; Clears the screen and prints
; the template for the game UI
; ------------------------------
	call Clrscr
	mov dh, 23
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET dashedLine
	call WriteString					; puts a dashed line to divide game screen and prompt screen

	ret
ResetScreen ENDP

END