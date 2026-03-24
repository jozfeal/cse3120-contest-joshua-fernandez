;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE AttackManager.inc
INCLUDE DrawManager.inc
INCLUDE Units.inc

ExitProcess PROTO, dwExitCode:DWORD

BOXROW EQU 24	; start of player's input box

; places the given char in front of the choice index when prompting
mPlaceCharForChoice MACRO char:REQ, choice:REQ
	push edx					; edx is used by mWrite so this is necessary to keep player choice
	mov dh, BOXROW
	add dh, choice
	mGotoxy 0, dh				; moves cursor to current choice
	mWrite char					; places given char
	pop edx
ENDM

; ENUM for player choices
ATTACK EQU 2	; starts at 2 because that is the line offset from BOXROW
DEFEND EQU 3
SPELL EQU 4

; keyboard scan codes for the directional arrow keys
LEFT EQU 4Bh 
RIGHT EQU 4Dh 
UP EQU 48h
DOWN EQU 50h
CONFIRM EQU 2Ch	; keyboard scan code for Z key
ESCAPE EQU 27h	; keyboard scan code for Escape key

.data
cursorInfo CONSOLE_CURSOR_INFO <25, FALSE>	; used to set the cursor invisible, learnt in Ch 11.1.10

.code
Main PROC PUBLIC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, eax, ADDR cursorInfo	; makes cursor invisible in cmd
	
	call InitializeUnits
	
	.REPEAT
		call ResetScreen
		mGetUnitName allies, 0				; name of first ally unit
		call PromptChoice
	
		.IF (al == ATTACK)					; 1 is the attack choice
			call ResetScreen
			call AttackUnit
			stc
		.ELSEIF (al >= 4)					; force stop game with an invalid instruction
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
; Returns number of choice selected in AL
; ------------------------------
	mGotoxy 0, BOXROW	; start of user entry box
	mWrite "Choose an action for "
	mov edx, eax		; inserts character name for choice prompt
	call WriteString
	mWriteLn ":"
	mWriteLn "> Attack"
	mWriteLn "  Defend"
	mWriteLn "  Spell"

	mov dl, ATTACK		; default choice is attack
	GetInput:			; waits for user to press a key, learnt in book Ch 11.1.4
		mov eax, 10		; 10 ms delay between checks
		call Delay
		call ReadKey	; keyboard scan code is stored in AH
		jz GetInput		; does nothing until user enters an input

	mPlaceCharForChoice " ", dl	; removes old player selection

	.IF (ah == CONFIRM)			; returns current choice selection
		mov al, 2
		ret

	.ELSEIF (ah == UP)
		nop
	.ENDIF

	mPlaceCharForChoice ">", dl	; selcts new player choice

	ret
PromptChoice ENDP

END Main