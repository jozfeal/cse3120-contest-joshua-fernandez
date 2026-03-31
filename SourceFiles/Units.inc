; Units.inc
; Has all the data regarding units and their procedures

ALLY EQU 0
ENEMY EQU 1
; role IDS
Warrior EQU 0
Archer EQU 1
Knight EQU 2

; units are made of this structure
UNIT STRUCT
	unitName BYTE 11 DUP(0)	; display name up to 10 chars
	role BYTE 11 DUP(0)		; display role up to 10 chars
	roleID BYTE 1			; corresponding ID for role
	maxHealth BYTE 20		; health values
	curHealth BYTE 20
	team BYTE ALLY			; team the unit belongs to
	pos BYTE ?				; position in team of this unit
	att BYTE 19				; attack
	def BYTE 1				; defense
	spe BYTE 1				; speed
Unit ENDS

InitializeUnits PROTO STDCALL				; stdcall is needed here to avoid compile time error
UpdateHealth PROTO STDCALL, unitOffset:DWORD, change:SBYTE
RandomTarget PROTO STDCALL

EXTERNDEF allies:UNIT
EXTERNDEF enemies:UNIT

; Macro that places the address of the field into eax, does not work for the first field in Unit 
mGetUnitField MACRO unitOffset, field:REQ
	mov eax, unitOffset
	add eax, UNIT.&field	; offset of team + unit in team + field in unit
	; https://forum.vcfed.org/index.php?threads/masm-struct-and-pointer-syntax.1241976/
ENDM

; Macro that gets the start of the given unit, equivalent to getting the unit's name
; teamEnum = ALLY|ENEMY, pos = 0|1|2|register
mGetUnit MACRO teamEnum:REQ, pos:REQ
	push ecx
	mov ecx, pos				; this allows me to use a register for pos
	mov eax, teamEnum
	.IF (eax == ALLY)			; offset of team + unit in team, name is at 0
		lea eax, allies
	.ELSEIF (eax == ENEMY)		; offset of team + unit in team, name is at 0
		lea eax, enemies
	.ENDIF
	.WHILE (ecx > 0)
		add eax, SIZEOF UNIT	; for every team position, increment pointer by unit size
		dec ecx
	.ENDW
	pop ecx
ENDM

; Macro to move a Unit to a position in either team
; teamEnum = ALLY|ENEMY, position = 0|1|2 
mMoveUnit MACRO unitObj:REQ, teamEnum:REQ, position:REQ
	push esi
	push edi
	push ecx
	push eax

	mov eax, teamEnum
	mov esi, OFFSET unitObj					; move data from object instance
	mov unitObj.team, teamEnum				; assign team to unit
	mov unitObj.pos, position				; assign position in team to unit
	.IF (eax == ALLY)						; places unit in ally team offset
		lea edi, allies[position * SIZEOF UNIT]
	.ELSEIF (eax == ENEMY)					; places unit in enemy team offset
		lea edi, enemies[position * SIZEOF UNIT]
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
