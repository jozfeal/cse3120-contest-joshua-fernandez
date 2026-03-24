; Units.inc
; Has all the data regarding units and their procedures

; units are made of this structure
Unit STRUCT 
	name BYTE 11 DUP(0)		; display name up to 10 chars
	role BYTE 11 DUP(0)		; display role up to 10 chars
	maxHealth BYTE 20		; health values
	curHealth BYTE 20
	att BYTE 1				; attack
	def BYTE 1				; defense
	spe BYTE 1				; speed
Unit ENDS

InitializeUnits PROTO

EXTERNDEF allies:Unit
EXTERNDEF enemies:Unit

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
