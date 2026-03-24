; draw_manager.asm
; Contains methods for drawing on the terminal
; Learnt how to use multiple files with this Stack Overflow post
; https://stackoverflow.com/questions/62618027/how-to-write-and-combine-multiple-source-files-for-a-project-in-masm

INCLUDE Irvine32.inc

.data
dashedLine BYTE 120 DUP("-"), 0		; as long as the default window opening size

.code

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