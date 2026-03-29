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
	.IF (change == 0)			; if there is no change, do nothing
		ret
	.ENDIF

	mGetUnitField unitOffset, pos
	mov dl, BYTE PTR [eax]	; get this unit's position in team

	mov al, UNITCOL
	inc dl					; aligns unit column offset correctly
	mul dl					; calculate column start of unit box
	add al, 8				; skip to curHealth amount in display
	push eax				; save column
	
	mGetUnitField unitOffset, team
	mov al, BYTE PTR [eax]	; get's this unit team to determine row
	.IF (al == ALLY)		; use ALLYROW for row if ally
		pop eax
		mGotoxy al, ALLYROW+2
	.ELSEIF (al == ENEMY)	; use ENEMYROW for row if enemy
		pop eax
		mGotoxy al, ENEMYROW+2
	.ELSE					; failsafe to keep stack working
		pop eax
	.ENDIF 

	mGetUnitField unitOffset, curHealth
	mov dl, BYTE PTR [eax]	; get this unit's current health
	mGetUnitField unitOffset, maxHealth	; goes before add dl, change so I can use SIGN?
	add dl, change			; apply change
	.IF (SIGN?)				; if health goes negative, bump it to 0
		mov dl, 0
	.ELSEIF (dl > BYTE PTR [eax])	; if health goes above max, bump it down to max
		mov dl, BYTE PTR [eax]
	.ENDIF
	mGetUnitField unitOffset, curHealth
	mov BYTE PTR [eax], dl	; update unit's actual health

	; this part is done with cmp and jumps because the .IF directive caused runtime errors
	cmp change, 0
	jne NotZero						; if no change, print health in white again, failsafe
	INVOKE ColorNumber, white, dl	
	jmp Finish						; skip next comparisons

	NotZero:
	jns Increase					; if not signed, health went up, skip this part
	INVOKE ColorNumber, yellow, dl	; yellow if health went down
	jmp Finish

	Increase:
	INVOKE ColorNumber, lightGreen, dl	; green if health went up
	Finish:
	 
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