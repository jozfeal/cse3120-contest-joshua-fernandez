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
TakeTurn PROTO, allyUnit:DWORD

; places the given char in front of the choice index when prompting
mPlaceCharForChoice MACRO char:REQ, choice:REQ
	push edx					; edx is used by mWrite so this is necessary to keep player choice
	mov dh, BOXROW
	add dh, choice
	mGotoxy 0, dh				; moves cursor to current choice
	mWrite char					; places given char
	pop edx
ENDM

; waits for player to press the confirm key before continuing
mWaitForConfirm MACRO
	LOCAL WaitForConfirm
	WaitForConfirm:
		call GetInput					; get a player input
		.IF (ah != CONFIRM)				; do not move on until player confirms
			jmp WaitForConfirm
		.ENDIF
ENDM

; to be used inside Main, checks for end conditions and jumps to appropiate instruction
mCheckEnd MACRO
	call CheckCombatEnd		; check if any team has won
	.IF (ZERO?) || (CARRY?)	; if either team won, prepare input box
		pushfd				; flags are not preserved by ResetBox and Gotoxy, so they need to be saved
		call ResetBox		; clear player box
		mGotoxy 0, BOXROW
		popfd
	.ENDIF
	
	.IF (ZERO?)				; zero flag indicates enemies win
		jmp EnemyWin
	.ELSEIF (CARRY?)		; carry flag indicates allies win
		jmp AllyWin
	.ENDIF
ENDM

.data
cursorInfo CONSOLE_CURSOR_INFO <25, FALSE>	; used to set the cursor invisible, learnt in Ch 11.1.10

.code
Main PROC PUBLIC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, eax, ADDR cursorInfo	; makes cursor invisible in cmd
	
	call Randomize			; gets a new random seed for the rng
	call InitializeUnits	; initializes basic units to use
	
	.REPEAT
		mov ecx, 0					; player turn
		.WHILE (ecx <= 2)
			mGetUnit ALLY, ecx
			mGetUnitField eax, curHealth
			mov dl, BYTE PTR [eax]	; get health of this unit
			.IF (dl == 0)			; if unit is dead, do not perform its turn
				jmp SkipAllyTurn
			.ENDIF
			
			mGetUnit ALLY, ecx		; gives turn to each ally unit
			INVOKE TakeTurn, eax	; given unit takes its turn
			
			SkipAllyTurn:
			inc ecx
			mCheckEnd
			call PrintUnits			; resets display after each turn
		.ENDW

		mov ecx, 0					; enemy turn
		.WHILE (ecx <= 2)
			mGetUnit ENEMY, ecx
			mGetUnitField eax, curHealth
			mov dl, BYTE PTR [eax]	; get health of this unit
			.IF (dl == 0)			; if unit is dead, do not perform its turn
				jmp SkipEnemyTurn
			.ENDIF

			mGetUnit ENEMY, ecx		; gives turn to each enemy unit
			mov edx, eax			; store attacking enemy
			call RandomTarget		; get ally to attack
			INVOKE AttackUnit, edx, eax	; enemy attacks selected ally
			mWaitForConfirm

			SkipEnemyTurn:
			inc ecx
			mCheckEnd
			call PrintUnits			; resets display after each turn
		.ENDW
	.UNTIL (0)						; infinite loop since game end logic is inside loop

	AllyWin:						; display win message and quit game
	mWrite "Congratulations, you win!"
	mWaitForConfirm
	INVOKE ExitProcess, 0

	EnemyWin:						; display loss message and quit game
	mWrite "Oh no, you lost!"
	mWaitForConfirm
	INVOKE ExitProcess,0
Main ENDP

; ------------------------------
TakeTurn PROC USES eax edx, allyUnit:DWORD
; Takes the offset of the ally unit taking a turn
; Returns nothing, all logic is handled inside method
; ------------------------------
	call ResetScreen
	mov eax, allyUnit	; makes PromptChoice work for ally unit
	call PromptChoice
	
	.IF (al == ATTACK)						; player attacking logic
		call ResetScreen
		call ChooseTarget					; get target for ally attack
		INVOKE AttackUnit, allyUnit, eax	; eax has enemy receiving attack
		mWaitForConfirm

	.ELSEIF (al == DEFEND) || (al == SPELL)	; don't do anything
		nop
	.ENDIF
	ret
TakeTurn ENDP

; ------------------------------
PromptChoice PROC USES edx
; Takes the offset of the character name in EAX
; Returns number of choice selected in AL
; ------------------------------
	mGotoxy 0, BOXROW	; start of user entry box
	mWrite "Choose an action for "
	INVOKE WriteName, eax	; writes unit name with correct color
	mWriteLn ":"
	mWriteLn "> Attack"
	mWriteLn "  Defend"
	mWriteLn "  Spell"

	mov dl, ATTACK			; default choice is attack
	WaitForConfirm:
		call GetInput		; get a player input

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
		.ENDIF

		mPlaceCharForChoice ">", dl	; highlights new player choice
	jmp WaitForConfirm
PromptChoice ENDP

; ------------------------------
ChooseTarget PROC USES edx ecx
; Takes no parameters
; Returns the offset of the target selected in EAX
; ------------------------------
		LOCAL choice[3]:DWORD

	mGotoxy 0, BOXROW		; start of user entry box
	mWriteLn "Choose a target:"

	mov ecx, 0				; tracks how many enemy units are alive / valid targets
	
	mGetUnit ENEMY, 0
	mGetUnitField eax, curHealth
	mov dl, BYTE PTR [eax]		; get health of unit
	.IF (dl != 0)				; only give choice if unit is alive
		mWrite"  "				; starts with the first enemy selected
		mGetUnit ENEMY, 0
		mov choice[ecx * 4], eax	; stores in choices
		INVOKE WriteName, eax	; puts the enemy as a choice
		call Crlf				; new line not included in WriteName
		inc cl					; count up how many units are being shown
	.ENDIF

	mGetUnit ENEMY, 1
	mGetUnitField eax, curHealth
	mov dl, BYTE PTR [eax]		; get health of unit
	.IF (dl != 0)				; only give choice if unit is alive
		mWrite"  "
		mGetUnit ENEMY, 1
		mov choice[ecx * 4], eax
		INVOKE WriteName, eax	; puts the enemy as a choice
		call Crlf
		inc cl					; count up how many units are being shown
	.ENDIF

	mGetUnit ENEMY, 2
	mGetUnitField eax, curHealth
	mov dl, BYTE PTR [eax]		; get health of unit
	.IF (dl != 0)				; only give choice if unit is alive
		mWrite"  "
		mGetUnit ENEMY, 2
		mov choice[ecx * 4], eax
		INVOKE WriteName, eax	; puts the enemy as a choice
		call Crlf
		inc cl					; count up how many units are being shown
	.ENDIF

	mov dl, 1				; default choice is first enemy
	mPlaceCharForChoice ">", dl	; marks first enemy as selected
	WaitForConfirm:
		call GetInput		; get a player input

		mPlaceCharForChoice " ", dl	; removes old player selection

		.IF (ah == CONFIRM)			; returns current choice selection
			and edx, 0Fh			; clears all bits above dl so it can be used as index
			dec edx					; makes edx point to correct unit position
			mov eax, choice[edx * 4]	; gets enemy choice corresponding to cursor position
			ret
		.ELSEIF (ah == UP)			; moves cursor up
			dec dl
			.IF (dl < 1)			; wraps around if scrolls above options
				mov dl, cl
			.ENDIF
		.ELSEIF (ah == DOWN)		; moves cursor down
			inc dl
			.IF (dl > cl)			; wraps around if scrolls below options
				mov dl, 1
			.ENDIF
		.ENDIF

		mPlaceCharForChoice ">", dl	; highlights new player choice
	jmp WaitForConfirm
ChooseTarget ENDP

; ------------------------------
GetInput PROC USES edx
; Takes no parameters
; Returns pressed key in AH
; Exits the game if escape key is pressed
; ------------------------------
	ScanInput:			; waits for user to press a key, learnt in book Ch 11.1.4
		mov eax, 5		; 5 ms delay between checks
		call Delay
		call ReadKey	; keyboard scan code is stored in AH
		jz ScanInput		; does nothing until user enters an input

	.IF (ah == ESCAPE)	; quit game no matter where it is at
		INVOKE ExitProcess, 0
	.ENDIF

	; check if input is any of the predetermined key
	.IF (ah != CONFIRM) && (ah != UP) && (ah != DOWN) && (ah != LEFT) && (ah != RIGHT)
		jmp ScanInput	; if not, read a new key in
	.ENDIF 
	ret
GetInput ENDP


; ------------------------------
CheckCombatEnd PROC USES eax ecx
; Takes no parameters
; Checks if either team has been fully defeated
; Sets carry flag ALLY team won, sets zero flag if ENEMY team won
; ------------------------------
	or ecx, 1 	; clear zero and carry flags first just in case
	clc
	
	mov ecx, 0
	.WHILE (ecx <= 2)					; go through every unit in ally team
		mGetUnit ALLY, ecx
		mGetUnitField eax, curHealth	; check if health has hit 0
		.IF (BYTE PTR [eax] != 0)
			jmp AllyAlive				; if any ally has more than 0 health, ALLY team has not been defeated yet
		.ENDIF
		inc ecx
	.ENDW
	test ecx, 0	; set zero flag to indicate enemies won
	ret			; return immediately without checking for ALLY win

	AllyAlive:
	mov ecx, 0
	.WHILE (ecx <= 2)					; go through every unit in enemy team
		mGetUnit ENEMY, ecx
		mGetUnitField eax, curHealth	; check if health has hit 0
		.IF (BYTE PTR [eax] != 0)
			jmp EnemyAlive				; if any ally has more than 0 health, ENEMY team has not been defeated yet
		.ENDIF
		inc ecx
	.ENDW
	stc			; set direction to indicate allies won

	EnemyAlive:		; neither team was defeated, don't set any flags
	ret
CheckCombatEnd ENDP

END Main