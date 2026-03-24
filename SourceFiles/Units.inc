; Units.inc
; Has all the data regarding units and their procedures

; units are made of this structure
UNIT STRUCT 
	name BYTE 11 DUP(0)		; display name up to 10 chars
	role BYTE 11 DUP(0)		; display role up to 10 chars
	maxHealth BYTE 20		; health values
	curHealth BYTE 20
	att BYTE 1				; attack
	def BYTE 1				; defense
	spe BYTE 1				; speed
Unit ENDS

InitializeUnits PROTO

EXTERNDEF allies:UNIT
EXTERNDEF enemies:UNIT

; Macro that places the address of the field into eax, does not work for the first field in Unit
mGetUnitField MACRO team:REQ, pos:REQ, field:REQ
	lea eax, team + (pos * SIZEOF Unit) + UNIT.&field	; offset of team + unit in team + field in unit
	; learned to use fields in structures as constants in the following thread
	; https://forum.vcfed.org/index.php?threads/masm-struct-and-pointer-syntax.1241976/
ENDM

; Macro that places the address of the unit name into eax, special case because Unit.name = 0 and MASM throws an error for some reason
mGetUnitName MACRO team:REQ, pos:REQ
	lea eax, team + (pos * SIZEOF UNIT)		; offset of team + unit in team, name is at 0
ENDM

; Macro to move a Unit to a position in either team
; team = allies|enemies, pos = 0|1|2 
mMoveUnit MACRO unitObj:REQ, team:REQ, pos:REQ
	push esi
	push edi
	push ecx

	mov esi, OFFSET unitObj				; move data from object instance
	lea edi, team[pos * SIZEOF UNIT]	; to corresponding place in Unit array
	mov ecx, SIZEOF UNIT
	rep movsb

	pop ecx
	pop edi
	pop esi
ENDM

; Macro to make a new ally unit, places it in the corresponding position
mAllyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName UNIT <name, role>
	.code
	mMoveUnit objName, allies, pos
ENDM

; Macro to make a new enemy unit, places it in the corresponding position
mEnemyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName UNIT <name, role>
	.code
	mMoveUnit objName, enemies, pos
ENDM
