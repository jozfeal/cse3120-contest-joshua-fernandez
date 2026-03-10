INCLUDE Irvine32.inc

.data
attackMsg BYTE "[Ally] attacked [Enemy] for [Dmg] damage!", 0

.code
; ------------------------------
Attack PROC USES edx eax
; Takes no parameters
; Displays an attack message with placeholder units and enemies
; ------------------------------
	mov dh, 24
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET attackMsg
	call WriteString
	call ReadInt					; waits for an enter before moving on
	ret
Attack ENDP

END