INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE Definitions.inc
INCLUDE Units.inc

.code
; ------------------------------
AttackUnit PROC USES edx eax, attackerOffset:DWORD, receiverOffset:DWORD
; Takes the offsets of the respective attacker and defender
; Displays an attack message with how much damage was dealt
; ------------------------------
	mGotoxy 0, BOXROW
	mov edx, attackerOffset		; writes attacker's name
	call WriteString
	mWrite " attacked "
	mov edx, receiverOffset		; writes receiver's name
	call WriteString
	mWrite " for 5 damage!"

	GetInput:			; waits for user to press a key, learnt in book Ch 11.1.4
		mov eax, 10		; 10 ms delay between checks
		call Delay
		call ReadKey	; keyboard scan code is stored in AH
		jz GetInput		; does nothing until user enters an input
	.IF (ah == CONFIRM)	; only continues once CONFIRM is pressed
		ret
	.ENDIF
	jmp GetInput		; forces CONFIRM
AttackUnit ENDP

END