; draw_manager.asm
; Contains methods for drawing on the terminal
; Learnt how to use multiple files with this Stack Overflow post
; https://stackoverflow.com/questions/62618027/how-to-write-and-combine-multiple-source-files-for-a-project-in-masm

INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Macros.inc
INCLUDE Definitions.inc
INCLUDE DrawManager.inc

.data
dashedLine BYTE 120 DUP("-"), 0		; as long as the default window opening size

.code

; ------------------------------
ResetScreen PROC USES edx
; Does not take any parameters
; Clears the screen and prints
; the template for the game UI
; ------------------------------
	call Clrscr
	mov dh, 23
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET dashedLine
	call WriteString					; puts a dashed line to divide game screen and prompt screen
	call PrintUnits

	ret
ResetScreen ENDP

; ------------------------------
PrintUnits PROC USES ecx edx eax
; Does not take any parameters
; Prints all the units of both teams on the screen
; ------------------------------
	mov ecx, 3					; loop 3 times, for each enemy unit
	PrintUnit:
		mov eax, UNITCOL
		mul ecx
		mGotoxy al, ENEMYROW	; calculate position with ecx and unit column spacing
		mov edx, ecx
		dec edx					; must do ecx - 1 to get correct unit index
		mGetUnit ENEMY, edx
		INVOKE WriteName, eax	; put corresponding unit name on screen
		loop PrintUnit
	ret
PrintUnits ENDP

; ------------------------------
WriteName PROC USES eax edx, unitOffset:DWORD
; Takes the address of a unit
; Returns nothing; writes unit's name cyan or magenta, depending on team
;------------------------------
	and eax, 0			; clear	eax first
	call GetTextColor	; get current colors used
	push eax			; save current colors for restoring later
	and eax, 11110000	; clears foreground colors bits
	push eax			; must be pushed to use GetUnitField macro properly
	mGetUnitField unitOffset, team	; check which team the unit is on
	mov al, [eax]		; get value of team instead of address to it
	.IF (al == ALLY)
		pop eax			; get background color back
		add eax, lightCyan	; add blue foreground for allies
	.ELSEIF (al == ENEMY)
		pop eax
		add eax, lightMagenta	; add red foreground for enemies
	.ELSE
		pop eax			; fail safe, simply makes name black
	.ENDIF
	call SetTextColor	; make name the correct color

	mov edx, unitOffset
	call WriteString	; write name with current color
	pop eax
	call SetTextColor	; set original colors back

	ret
WriteName ENDP

END