BOXROW EQU 24	; start of player's input box

; ENUM for player choices
ATTACK EQU 1	; starts at 1 because that is the line offset from BOXROW
DEFEND EQU 2
SPELL EQU 3

; keyboard scan codes for the directional arrow keys
LEFT EQU 4Bh 
RIGHT EQU 4Dh 
UP EQU 48h
DOWN EQU 50h
CONFIRM EQU 2Ch	; keyboard scan code for Z key
ESCAPE EQU 27h	; keyboard scan code for Escape key

; writes the name of the unit in the given offset, makes color blue or red depending on team
mWriteName MACRO unitOffset:REQ
	push edx			; used by macro, must be restored
	push eax

	and eax, 0			; clear	eax first
	call GetTextColor	; get current colors used
	push eax			; save current colors for restoring later
	and eax, 11110000	; clears foreground colors bits
	push eax			; must be pushed to use GetUnitField macro properly
	mGetUnitField unitOffset, team	; check which team the unit is on
	mov al, [eax]		; get value of team instead of address to it
	.IF (al == ALLY)
		pop eax			; get background color back
		add eax, blue	; add blue foreground for allies
	.ELSEIF (al == ENEMY)
		pop eax
		add eax, red	; add red foreground for enemies
	.ELSE
		pop eax			; fail safe, simply makes name black
	.ENDIF
	call SetTextColor	; make name the correct color

	mov edx, unitOffset
	call WriteString	; write name with current color
	pop eax
	call SetTextColor	; set original colors back

	pop eax
	pop edx
ENDM