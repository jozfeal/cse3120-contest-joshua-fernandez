.model flat,stdcall
INCLUDE Units.inc

; Macro to move a Unit to a position in either team
; team = allies|enemies, pos = 0|1|2 
mMoveUnit MACRO unit:REQ, team:REQ, pos:REQ
	push esi
	push edi
	push ecx

	mov esi, OFFSET unit				; move data from object instance
	lea edi, team[pos * SIZEOF Unit]	; to corresponding place in Unit array
	mov ecx, SIZEOF Unit
	rep movsb

	pop ecx
	pop edi
	pop esi
ENDM

; Macro to make a new ally unit, places it in the corresponding position
mAllyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName Unit <name, role>
	.code
	mMoveUnit objName, allies, pos
ENDM

; Macro to make a new enemy unit, places it in the corresponding position
mEnemyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName Unit <name, role>
	.code
	mMoveUnit objName, enemies, pos
ENDM

.data
allies Unit 3 DUP (<>)
enemies Unit 3 DUP(<>)

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

END