; draw_manager.asm
; Contains methods for drawing on the terminal
; Learnt how to use multiple files with this Stack Overflow post
; https://stackoverflow.com/questions/62618027/how-to-write-and-combine-multiple-source-files-for-a-project-in-masm

INCLUDE Irvine32.inc

.data
PumpkinBuffer BYTE 20, 11			; width, height of the image stored int the following addresses 
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
Draw PROC
	mov ebx, 0
	mov bl, PumpkinBuffer[0]		; store the width
	mov ecx, 0
	mov cl, PumpkinBuffer[1]		; store the height (for the loop)
	mov esi, 0
	mov edx, OFFSET PumpkinBuffer	; point to buffer
	add edx, 2
	L1:
		add edx, esi					; go down to corresponding line
		call WriteString
		call Crlf
		add esi, ebx					; skip bytes using width
		loop L1
	ret
Draw ENDP

END