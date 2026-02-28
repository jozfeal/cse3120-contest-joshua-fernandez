;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc

ExitProcess PROTO, dwExitCode:DWORD
ResetScreen PROTO
Draw PROTO
Attack PROTO

.data
placeholderName BYTE "[Name]", 0

.code
Main PROC
	call ResetScreen
	mov dx, 0
	call Gotoxy								; moving the cursor back to the top for drawing
	call Draw
	mov eax, OFFSET placeholderName			; Changed later for actual character name
	call PromptChoice

	.IF (eax == 1)
		call Attack
	.ENDIF

	INVOKE ExitProcess,0
Main ENDP

.data
chooseActionMsg BYTE "Choose an action for [Name]:", 0	; Choices for the player to choose from
attackChoiceMsg BYTE "1. Attack", 0
defendChoiceMsg BYTE "2. Defend", 0
spellChoiceMsg BYTE "3. Spell", 0
promptSpaceMsg BYTE "> ", 0

.code
; ------------------------------
PromptChoice PROC USES edx
; Takes the offset of the character name in EAX
; Returns number of choice selected in EAX
; ------------------------------
	mov dh, 24							; Starting row position of the prompt
	mov dl, 0
	call GotoXY
	push edx							; Push edx to keep using original dh value
	mov edx, OFFSET chooseActionMsg		; Write correspodning message
	call WriteString
	pop edx								; Pop after writing to reuse dh value
	
	inc dh								; inc dh to easily switch starting position with previous print
	call GotoXY
	push edx
	mov edx, OFFSET attackChoiceMsg
	call WriteString
	pop edx

	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET defendChoiceMsg
	call WriteString
	pop edx

	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET spellChoiceMsg
	call WriteString
	pop edx

	inc dh
	call GotoXY
	mov edx, OFFSET promptSpaceMsg		; no need to push since dh won't be reused
	call WriteString
	call ReadInt						; get user's input and store in eax

	ret
PromptChoice ENDP

END Main