;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Definitions.inc
INCLUDE Macros.inc

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
UpdateHealth PROC USES eax edx, unitOffset:DWORD, change:DWORD
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
	
	mGetUnitField unitOFfset, team
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

	mov edx, ecx
	dec edx
	;mGetUnit ALLY, edx
	;mGetUnitField eax, curHealth	; get this unit's current health
	mov edx, eax			; save address of curHP
	and eax, 0				; clear upper half of eax
	mov al, BYTE PTR [edx]	; dereference from address
	call WriteDec			; display current health
	
	ret
UpdateHealth ENDP

END