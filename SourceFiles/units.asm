;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Definitions.inc
INCLUDE Macros.inc
INCLUDE DrawManager.inc

.data
allies UNIT 3 DUP (<>)
enemies UNIT 3 DUP(<>)

.code
InitializeUnits PROC
	; Initializes constant characters to test with for each team
	mAllyUnit ally1, "Edelgard", "Fighter", 0
	mAllyUnit ally2, "Dimitri", "Soldier", 1
	mAllyUnit ally3, "Claude", "Archer", 2
	mEnemyUnit enemy1, "Jeritza", "Paladin", 0
	mEnemyUnit enemy2, "Rhea", "Dragon", 1
	mEnemyUnit enemy3, "Nemesis", "Liberator", 2

	ret
InitializeUnits ENDP

; ------------------------------
UpdateHealth PROC USES eax edx, unitOffset:DWORD, change:SBYTE
; Takes offset of the unit whose health is changing and the change in health
; Change can be negative or positive
; Returns number of choice selected in AL
; ------------------------------
	.IF (change == 0)		; if there is no change, do nothing
		ret
	.ENDIF

	mGetUnitField unitOffset, pos
	mov dl, BYTE PTR [eax]	; get this unit's position in team

	mov al, UNITCOL
	mul dl					; calculate column start of unit box
	add al, 8				; skip to curHealth amount in display
	push eax				; save column
	
	mGetUnitField unitOffset, team
	mov al, BYTE PTR [eax]	; get's this unit team to determine row
	.IF (al == ALLY)		; use ALLYROW for row if ally
		pop eax
		mGotoxy al, ALLYROW
	.ELSEIF (al == ENEMY)	; use ENEMYROW for row if enemy
		pop eax
		mGotoxy al, ENEMYROW
	.ELSE					; failsafe to keep stack working
		pop eax
	.ENDIF 

	mGetUnitField unitOffset, curHealth
	mov dl, BYTE PTR [eax]	; get this unit's current health
	add dl, change			; apply change
	mGetUnitField unitOffset, maxHealth
	.IF (SIGN?)				; if health goes negative, bump it to 0
		mov dl, 0
	.ELSEIF (dl > BYTE PTR [eax])	; if health goes above max, bump it down to max
		mov dl, BYTE PTR [eax]
	.ENDIF
	mGetUnitField unitOffset, curHealth
	mov BYTE PTR [eax], dl	; update unit's actual health

	.IF (change < 0)		; if health went down, display new health in yellow
		INVOKE ColorNumber, yellow, BYTE PTR [eax]
	.ELSEIF (change > 0)	; if health went up, display new health in green
		INVOKE ColorNumber, lightGreen, BYTE PTR [eax]
	.ELSE					; failsafe, new health in white
		INVOKE ColorNumber, white, BYTE PTR [eax]
	.ENDIF
	 
	mWrite "/"				; divider between current and max hp
	mGetUnitField unitOffset, maxHealth	; get max health
	mov edx, eax			; save address of maxHP
	and eax, 0				; clear upper half of eax
	mov al, BYTE PTR [edx]	; dereference from address
	call WriteDec

	mWriteSpace 4			; erases trailing chars behind max health, won't work if maxHealth > 999
	
	ret
UpdateHealth ENDP

END