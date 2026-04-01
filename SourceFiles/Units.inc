; Units.inc
; Has all the data regarding units and their procedures

ALLY EQU 0
ENEMY EQU 1
; role IDS
WARRIOR EQU 1
ARCHER EQU 2
KNIGHT EQU 3

; units are made of this structure
UNIT STRUCT
	unitName BYTE 11 DUP(0)	; display name up to 10 chars
	roleID BYTE 1			; corresponding ID for role
	role BYTE 11 DUP(0)		; display role up to 10 chars
	team BYTE ALLY			; team the unit belongs to
	pos BYTE ?				; position in team of this unit
	curHealth BYTE 20		; health values
	maxHealth BYTE 20		
	att BYTE 19				; attack
	def BYTE 1				; defense
	spe BYTE 1				; speed
Unit ENDS

InitializeUnits PROTO STDCALL				; stdcall is needed here to avoid compile time error
UpdateHealth PROTO STDCALL, unitOffset:DWORD, change:SBYTE
RandomTarget PROTO STDCALL
SetRole PROTO STDCALL, unitOffset:DWORD
SetStats PROTO STDCALL, unitOffset:DWORD
CreateUnit PROTO STDCALL, nameOffset:DWORD, role:BYTE
MoveUnit PROTO STDCALL, unitOffset:DWORD, team:BYTE, position:BYTE

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