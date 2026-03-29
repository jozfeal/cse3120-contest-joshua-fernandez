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
	mGotoxy 0, 23
	mov edx, OFFSET dashedLine
	call WriteString					; puts a dashed line to divide game screen and prompt screen
	call PrintUnits

	ret
ResetScreen ENDP

; prints the team given, assuming that ecx is used as a counter for the units in the team outside this macro
mPrintTeam MACRO team:REQ
	mov eax, UNITCOL
	mul ecx
	mGotoxy al, team&ROW	; calculate position with ecx and unit column spacing
	push eax				; saved for next line in unit display
	
	mWrite "Name: "
	mov edx, ecx
	dec edx					; must do ecx - 1 to get correct unit index
	mGetUnit team, edx
	INVOKE WriteName, eax	; put corresponding unit name on screen
	
	pop eax
	mGotoxy al, team&ROW+1	; get column back and go to next line
	push eax
		mWrite "Role: "
	mov edx, ecx
	dec edx
	mGetUnit team, edx
	mGetUnitField eax, role	; get unit's role to print
	mov edx, eax
	call WriteString		; print unit role

	pop eax
	mGotoxy al, team&ROW+2	; get column back and go to next line
		
	mWrite "Health: "		; display both max and current hp
	mov edx, ecx
	dec edx
	push edx				; keep edx for next use, since it is about to be changed
	mGetUnit team, edx
	mGetUnitField eax, curHealth	; get this unit's current health
	mov edx, eax			; save address of curHP
	and eax, 0				; clear upper half of eax
	mov al, BYTE PTR [edx]	; dereference from address
	call WriteDec			; display current health
	mWrite "/"				; divider between current and max hp
	pop edx					; get unit index back
	mGetUnit team, edx
	mGetUnitField eax, maxHealth	; get max health
	mov edx, eax			; save address of maxHP
	and eax, 0				; clear upper half of eax
	mov al, BYTE PTR [edx]	; dereference from address
	call WriteDec
ENDM

; ------------------------------
PrintUnits PROC USES ecx edx eax
; Does not take any parameters
; Prints all the units of both teams on the screen
; ------------------------------
	mov ecx, 3				; loop 3 times, for each enemy unit
	PrintUnit:
		mPrintTeam ENEMY
		mPrintTeam ALLY
		dec ecx
		jnz PrintUnit		; loop does not reach so I used jnz
	ret
PrintUnits ENDP

; ------------------------------
WriteName PROC USES eax edx, unitOffset:DWORD
; Takes the address of a unit
; Returns nothing; writes unit's name cyan or red, depending on team
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
		add eax, lightRed	; add red foreground for enemies
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

; ------------------------------
ColorNumber PROC USES eax, color:DWORD, number:DWORD
; Takes the number to be displayed
; Displays the given number in color, keeping background color the same
; ------------------------------
	and eax, 0			; clear	eax first
	call GetTextColor	; get current colors used
	push eax			; save current colors for restoring later
	and eax, 11110000	; clears foreground colors bits
	add eax, color		; makes foreground yellow
	call SetTextColor	; change to yellow

	mov eax, number
	call WriteDec		; write out number in yellow

	pop eax
	call SetTextColor	; set original colors back

	ret
ColorNumber ENDP

END