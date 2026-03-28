;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc

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
UpdateHealth PROC USES eax, unitOffset:DWORD, change:DWORD
; Takes offset of the unit whose health is changing and the change in health
; Change can be negative or positive
; Returns number of choice selected in AL
; ------------------------------
	mov eax, unitOffset
	mov eax, change
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