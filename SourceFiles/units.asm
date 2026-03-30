;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Definitions.inc
INCLUDE Macros.inc
INCLUDE DrawManager.inc

.data
allies UNIT 3 DUP (<>)
enemies UNIT 3 DUP(<>)

.code
InitializeUnits PROC
	; Initializes constant characters to test with for each team
	mAllyUnit ally1, "Edelgard", "Fighter", 0
	mAllyUnit ally2, "Dimitri", "Soldier", 1
	mAllyUnit ally3, "Claude", "Archer", 2
	mEnemyUnit enemy1, "Jeritza", "Paladin", 0
	mEnemyUnit enemy2, "Rhea", "Dragon", 1
	mEnemyUnit enemy3, "Nemesis", "Liberator", 2

	ret
InitializeUnits ENDP

; ------------------------------
UpdateHealth PROC USES eax edx, unitOffset:DWORD, change:SBYTE
; Takes offset of the unit whose health is changing and the change in health
; Change can be negative or positive
; Returns number of choice selected in AL
; ------------------------------
	.IF (change == 0)			; if there is no change, do nothing
		ret
	.ENDIF

	mGetUnitField unitOffset, pos
	mov dl, BYTE PTR [eax]	; get this unit's position in team

	mov al, UNITCOL
	inc dl					; aligns unit column offset correctly
	mul dl					; calculate column start of unit box
	add al, 8				; skip to curHealth amount in display
	push eax				; save column
	
	mGetUnitField unitOffset, team
	mov al, BYTE PTR [eax]	; get's this unit team to determine row
	.IF (al == ALLY)		; use ALLYROW for row if ally
		pop eax
		mGotoxy al, ALLYROW+2
	.ELSEIF (al == ENEMY)	; use ENEMYROW for row if enemy
		pop eax
		mGotoxy al, ENEMYROW+2
	.ELSE					; failsafe to keep stack working
		pop eax
	.ENDIF 

	mGetUnitField unitOffset, curHealth
	mov dl, BYTE PTR [eax]	; get this unit's current health
	mGetUnitField unitOffset, maxHealth	; goes before add dl, change so I can use SIGN?
	add dl, change			; apply change
	.IF (SIGN?)				; if health goes negative, bump it to 0
		mov dl, 0
	.ELSEIF (dl > BYTE PTR [eax])	; if health goes above max, bump it down to max
		mov dl, BYTE PTR [eax]
	.ENDIF
	mGetUnitField unitOffset, curHealth
	mov BYTE PTR [eax], dl	; update unit's actual health

	; this part is done with cmp and jumps because the .IF directive caused runtime errors
	cmp change, 0
	jne NotZero						; if no change, print health in white again, failsafe
	INVOKE ColorNumber, white, dl	
	jmp Finish						; skip next comparisons

	NotZero:
	jns Increase					; if not signed, health went up, skip this part
	INVOKE ColorNumber, yellow, dl	; yellow if health went down
	jmp Finish

	Increase:
	INVOKE ColorNumber, lightGreen, dl	; green if health went up
	Finish:
	 
	mWrite "/"				; divider between current and max hp
	mGetUnitField unitOffset, maxHealth	; get max health
	mov edx, eax			; save address of maxHP
	and eax, 0				; clear upper half of eax
	mov al, BYTE PTR [edx]	; dereference from address
	call WriteDec

	mWriteSpace 4			; erases trailing chars behind max health, won't work if maxHealth > 999
	
	ret
UpdateHealth ENDP

; ------------------------------
RandomTarget PROC USES edx ecx
; Takes no parameters
; Returns in EAX a random target from ALLY team for an enemy to target
; Uses weighted probability, lower HP enemies are more likely to be chosen
; ------------------------------
		LOCAL weight[3]:WORD	; weight for each ally to be picked
	mov ecx, 0
	.WHILE (ecx <= 2)			; go through every ally unit
		mGetUnit ALLY, ecx
		mGetUnitField eax, curHealth
		mov dl, BYTE PTR [eax]	; get their current health
		mov al, 255
		sub al, dl				; get inverse of current health relative to maximum possible health (BYTE)
		movzx dx, al			; turn value into word for use later
		mov weight[ecx], dx		; store as weight for this unit
		
		inc ecx
	.ENDW

	and eax, 0			; clear upper eax to prevent errors
	mov ax, weight[0]	; add all weights together to get total range
	add ax, weight[1]	; ax is used because if total weight exceeds 255, it breaks
	add ax, weight[2]
	call RandomRange
	inc ax				; makes range 1-n instead of 0-(n-1) so that weights can work correctly

	.IF (ax <= weight[0])
		mov ecx, 0		; first ally unit is chosen
	.ELSEIF (ax <= weight[1] + weight[0])
		mov ecx, 1		; second ally unit is chosen
	.ELSE
		mov ecx, 2		; third ally unit is chosen
	.ENDIF

	mGetUnit ALLY, ecx	; return the unit that was randomly chosen in eax
	ret
RandomTarget ENDP

END