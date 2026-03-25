; Units.inc
; Has all the data regarding units and their procedures

ALLY EQU 0
ENEMY EQU 1

; units are made of this structure
UNIT STRUCT 
	name BYTE 11 DUP(0)		; display name up to 10 chars
	role BYTE 11 DUP(0)		; display role up to 10 chars
	maxHealth BYTE 20		; health values
	curHealth BYTE 20
	team BYTE ALLY			; team the unit belongs to
	att BYTE 2				; attack
	def BYTE 1				; defense
	spe BYTE 1				; speed
Unit ENDS

InitializeUnits PROTO

EXTERNDEF allies:UNIT
EXTERNDEF enemies:UNIT

; Macro that places the address of the field into eax, does not work for the first field in Unit
; teamEnum = ALLY|ENEMY, pos = 0|1|2 
mGetUnitField MACRO teamEnum:REQ, pos:REQ, field:REQ
	mGetUnit teamEnum, pos
	add eax, UNIT.&field	; offset of team + unit in team + field in unit
	; https://forum.vcfed.org/index.php?threads/masm-struct-and-pointer-syntax.1241976/
ENDM

; Macro that gets the start of the given unit, equivalent to getting the unit's name
; teamEnum = ALLY|ENEMY, pos = 0|1|2 
mGetUnit MACRO teamEnum:REQ, pos:REQ
	mov eax, teamEnum
	.IF (eax == ALLY)						; offset of team + unit in team, name is at 0
		lea eax, allies + (pos * SIZEOF UNIT)
	.ELSEIF (eax == ENEMY)					; offset of team + unit in team, name is at 0
		lea eax, enemies + (pos * SIZEOF UNIT)
	.ENDIF
ENDM

; Macro to move a Unit to a position in either team
; teamEnum = ALLY|ENEMY, pos = 0|1|2 
mMoveUnit MACRO unitObj:REQ, teamEnum:REQ, pos:REQ
	push esi
	push edi
	push ecx
	push eax

	mov eax, teamEnum
	mov esi, OFFSET unitObj					; move data from object instance
	mov unitObj.team, teamEnum				; assign team to unit
	.IF (eax == ALLY)						; places unit in ally team offset
		lea edi, allies[pos * SIZEOF UNIT]
	.ELSEIF (eax == ENEMY)					; places unit in enemy team offset
		lea edi, enemies[pos * SIZEOF UNIT]
	.ENDIF
	mov ecx, SIZEOF UNIT					; copy all of unit's fields
	rep movsb								; copy unit to place in team

	pop eax
	pop ecx
	pop edi
	pop esi
ENDM

; Macro to make a new ally unit, places it in the corresponding position
mAllyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName UNIT <name, role>
	.code
	mMoveUnit objName, ALLY, pos
ENDM

; Macro to make a new enemy unit, places it in the corresponding position
mEnemyUnit MACRO objName:REQ, name:REQ, role:REQ, pos:REQ
	.data
	objName UNIT <name, role>
	.code
	mMoveUnit objName, ENEMY, pos
ENDM
