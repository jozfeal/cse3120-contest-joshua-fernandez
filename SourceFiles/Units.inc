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