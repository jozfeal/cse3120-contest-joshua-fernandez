;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE AttackManager.inc
INCLUDE DrawManager.inc
INCLUDE Units.inc
INCLUDE Definitions.inc

ExitProcess PROTO, dwExitCode:DWORD

; places the given char in front of the choice index when prompting
mPlaceCharForChoice MACRO char:REQ, choice:REQ
	push edx					; edx is used by mWrite so this is necessary to keep player choice
	mov dh, BOXROW
	add dh, choice
	mGotoxy 0, dh				; moves cursor to current choice
	mWrite char					; places given char
	pop edx
ENDM

.data
cursorInfo CONSOLE_CURSOR_INFO <25, FALSE>	; used to set the cursor invisible, learnt in Ch 11.1.10

.code
Main PROC PUBLIC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, eax, ADDR cursorInfo	; makes cursor invisible in cmd
	
	call InitializeUnits
	
	.REPEAT
		call ResetScreen
		mGetUnit allies, 0				; name of first ally unit
		call PromptChoice
	
		.IF (al == ATTACK)					; 1 is the attack choice
			call ResetScreen
			call AttackUnit
			stc
		.ELSEIF (al == DEFEND) || (al == SPELL)	; don't do anything
			stc
		.ELSE								; end the game
			clc
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
	WaitForConfirm:
		push edx			; ReadKey overrides edx, so it needs to be saved
		GetInput:			; waits for user to press a key, learnt in book Ch 11.1.4
			mov eax, 10		; 10 ms delay between checks
			call Delay
			call ReadKey	; keyboard scan code is stored in AH
			jz GetInput		; does nothing until user enters an input
		pop edx

		mPlaceCharForChoice " ", dl	; removes old player selection

		.IF (ah == CONFIRM)			; returns current choice selection
			mov al, dl
			ret
		.ELSEIF (ah == UP)			; moves cursor up
			dec dl
			.IF (dl < ATTACK)		; wraps around if scrolls above options
				mov dl, SPELL
			.ENDIF
		.ELSEIF (ah == DOWN)		; moves cursor down
			inc dl
			.IF (dl > SPELL)		; wraps around if scrolls below options
				mov dl, ATTACK
			.ENDIF
		.ELSE						; no instruction, ends game
			mov al, -1
			ret
		.ENDIF

		mPlaceCharForChoice ">", dl	; highlights new player choice
	jmp WaitForConfirm
PromptChoice ENDP

END Main