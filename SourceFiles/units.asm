;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Definitions.inc
INCLUDE Macros.inc
INCLUDE DrawManager.inc

.data
allies UNIT 3 DUP (<>)
enemies UNIT 3 DUP(<>)

; base stats for each of the classes in order: maxHP, att, def, spe
warriorStats BYTE 55, 25, 15, 10
archerStats BYTE 35, 32, 12, 13
knightStats BYTE 65, 21, 20, 6

.code
InitializeUnits PROC
	; Initializes constant characters to test with for each team
	mAllyUnit ally1, "Sylvain", "Warrior", 0
	mAllyUnit ally2, "Dimitri", "Knight", 1
	mAllyUnit ally3, "Ashe", "Archer", 2
	mEnemyUnit enemy1, "Bernie", "Archer", 0
	mEnemyUnit enemy2, "Caspar", "Warrior", 1
	mEnemyUnit enemy3, "Edelgard", "Knight", 2

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
		
		.IF (dl != 0)			; only calculates weight if unit is alive
			mGetUnit ALLY, ecx
			mGetUnitField eax, maxHealth
			movzx ax, BYTE PTR [eax]	; get their max health
		
			div dl					; divide maxHealth/curHealth
			push eax				; store division result
			movzx ax, al			; get quotient, lower health = higher weight = higher chance to be targeted
			mov dx, 10
			mul dx					; multiply quotient by 10, giving it a heavier weight than remainder
			pop edx
			movzx dx, dh			; get remainder into dx
			add ax, dx				; add remainder to weight
			mov weight[ecx * 2], ax		; store as weight for this unit
		
		.ELSE
			mov ax, 0				; if unit is dead, they have a weight of zero
			mov weight[ecx * 2], ax	; prevents unit from behing chosen
		.ENDIF
		
		inc ecx
	.ENDW

	and eax, 0			; clear upper eax to prevent errors
	mov ax, weight[0]	; add all weights together to get total range
	add ax, weight[2]	; ax is used because if total weight exceeds 255, it breaks
	add ax, weight[4]
	call RandomRange
	inc ax				; makes range 1-n instead of 0-(n-1) so that weights can work correctly

	mov dx, weight[0]	; put first two eights in dx for elseif later
	add dx, weight[2]
	.IF (ax <= weight[0])
		mov ecx, 0		; first ally unit is chosen
	.ELSEIF (ax <= dx)
		mov ecx, 1		; second ally unit is chosen
	.ELSE
		mov ecx, 2		; third ally unit is chosen
	.ENDIF

	mGetUnit ALLY, ecx	; return the unit that was randomly chosen in eax
	ret
RandomTarget ENDP

; ------------------------------
SetStats PROC USES edx ecx, unitOffset:DWORD
; Takes the unit whose stats will be set
; Gives the units its starting stats based off their class
; There is a random variance to their stats
; ------------------------------
	mGetUnitField unitOffset, roleID
	ret
SetStats ENDP
END