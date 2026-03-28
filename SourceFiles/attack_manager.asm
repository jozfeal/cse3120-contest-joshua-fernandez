INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE Definitions.inc
INCLUDE Units.inc

WriteName PROTO stdcall, unitOffset:DWORD

.code
; ------------------------------
AttackUnit PROC USES edx eax ecx, attackerOffset:DWORD, receiverOffset:DWORD
; Takes the offsets of the respective attacker and defender
; Displays an attack message with how much damage was dealt
; ------------------------------
	mGotoxy 0, BOXROW			; start of player box
	INVOKE WriteName, attackerOffset
	mWrite " attacked "
	INVOKE WriteName, receiverOffset
	mWrite " for "

	mGetUnitField attackerOffset, att	; get attacker's attack value
	mov dl, BYTE PTR [eax]
	mGetUnitField receiverOffset, def	; get receiver's defense value
	sub dl, BYTE PTR [eax]

	.IF (SIGN?)			; sign flag indicates negative damage
		mov eax, 0		; negative damage is simply bumped up to 0
	.ELSE
		and eax, 0		; clear eax
		mov al, dl		; move damage amount to al for printing
	.ENDIF
	call WriteDec		; display damage amount

	mWrite " damage!"
	
	mov ecx, eax		; move damage outside of eax to use eax
	mGetUnitField receiverOffset, curHealth
	and edx, 0
	mov dl, BYTE PTR [eax]	; get unit's current health in dl
	sub dl, cl			; substracts damage from receiver's health
	.IF (SIGN?)			; prevents health from going negative
		mov BYTE PTR [eax], 0
	.ELSE				; otherwise updates health for receiver
		mov BYTE PTR [eax], dl
	.ENDIF

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