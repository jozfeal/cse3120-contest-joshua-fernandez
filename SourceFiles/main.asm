;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE AttackManager.inc
INCLUDE DrawManager.inc
INCLUDE Units.inc

ExitProcess PROTO, dwExitCode:DWORD

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
	mWriteLn "1. Attack"
	mWriteLn "2. Defend"
	mWriteLn "3. Spell"
	mWrite "> "
	call ReadInt		; get user's input and store in eax

	ret
PromptChoice ENDP

END Main