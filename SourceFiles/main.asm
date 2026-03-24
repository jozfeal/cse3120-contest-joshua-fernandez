;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE AttackManager.inc
INCLUDE DrawManager.inc
INCLUDE Units.inc

ExitProcess PROTO, dwExitCode:DWORD

; keyboard scan codes for the directional arrow keys
LEFT = 4Bh 
RIGHT = 4Dh 
UP = 48h
DOWN = 50h
CONFIRM = 2Ch	; keyboard scan code for Z key
ESCAPE = 27h	; keyboard scan code for Escape key

.code
Main PROC PUBLIC
	call InitializeUnits
	
	.REPEAT
		call ResetScreen
		mGetUnitName allies, 0				; name of first ally unit
		call PromptChoice
	
		.IF (eax == 1)						; 1 is the attack choice
			call ResetScreen
			call Attack
			stc
		.ELSEIF (eax >= 4)					; force stop game with an invalid instruction
			clc
		.ELSE								; go to next turn in game
			stc
		.ENDIF
	.UNTIL (!CARRY?)						; the carry flag is used as a boolean to know if combat should end

	INVOKE ExitProcess,0
Main ENDP

; ------------------------------
PromptChoice PROC USES edx
; Takes the offset of the character name in EAX
; Returns number of choice selected in EAX
; ------------------------------
	mGotoxy 0, 24		; start of user entry box
	mWrite "Choose an action for "
	mov edx, eax		; inserts character name for choice prompt
	call WriteString
	mWriteLn ":"
	mWriteLn "  Attack"
	mWriteLn "  Defend"
	mWriteLn "  Spell"
	GetInput:			; waits for user to press a key, learnt in book Ch 11.1.4
		mov eax, 10		; 10 ms delay between checks
		call Delay
		call ReadKey	; keyboard scan code is stored in AH
		jz GetInput		; does nothing until user enters an input

	cmp ah, DOWN
	jne no
	mov eax, 1
	jmp ended
	no: 
	mov eax, 5
	ended:
	ret
PromptChoice ENDP

END Main