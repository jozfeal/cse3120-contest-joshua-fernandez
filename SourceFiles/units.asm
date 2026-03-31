;.model flat,stdcall
INCLUDE Irvine32.inc
INCLUDE Units.inc
INCLUDE Definitions.inc
INCLUDE Macros.inc
INCLUDE DrawManager.inc

.data
allies UNIT 3 DUP (<>)
enemies UNIT 3 DUP(<>)
baseUnit UNIT <>		; default unit to be used for new unit creation from which data is copied

; default enemy names to use for demo
enemy1Name BYTE "Camus", 6 DUP(0)
enemy2Name BYTE "Bob", 8 DUP(0)
enemy3Name BYTE "Saphira", 4 DUP(0)

; base stats for each of the classes in order: maxHP, att, def, spe
noRoleStats BYTE 20, 5, 5, 5		; failsafe
warriorStats BYTE 55, 31, 15, 10
archerStats BYTE 35, 38, 12, 13
knightStats BYTE 65, 27, 20, 6

; role names for each of the classes, wih trailing 0's up to 11 chars
noRoleName BYTE "No Role", 4 DUP(0)		; failsafe
warriorName BYTE "Warrior", 4 DUP(0)
archerName BYTE "Archer", 5 DUP(0)
knightName BYTE "Knight", 5 DUP(0)

.code
InitializeUnits PROC
	; Initializes constant characters to test with for each team
	mAllyUnit ally1, "Sylvain", WARRIOR, 0
	mAllyUnit ally2, "Dimitri", KNIGHT, 1
	mAllyUnit ally3, "Ashe", ARCHER, 2
	mEnemyUnit enemy1, "Bernie", ARCHER, 0
	mEnemyUnit enemy2, "Caspar", WARRIOR, 1
;	mEnemyUnit enemy3, "Edelgard", KNIGHT, 2
	INVOKE CreateUnit, ADDR enemy3Name, KNIGHT
	INVOKE MoveUnit, ADDR baseUnit, ENEMY, 2

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
SetStats PROC USES eax edx ecx esi edi, unitOffset:DWORD
; Takes the unit whose stats will be set
; Gives the units its starting stats based off their class
; There is a random variance to their stats
; ------------------------------
	mGetUnitField unitOffset, roleID
	mov dl, BYTE PTR [eax]		; gets this unit's roleID
	.IF (dl == WARRIOR)			
		mov esi, OFFSET warriorStats
	.ELSEIF (dl == ARCHER)
		mov esi, OFFSET archerStats
	.ELSEIF (dl == KNIGHT)
		mov esi, OFFSET knightStats
	.ELSE						; failsafe, puts no role
		mov esi, OFFSET noRoleStats
	.ENDIF
	
	mGetUnitField unitOffset, maxHealth
	mov edi, eax				; puts the destination for the role stats
	mov	ecx, 4					; all stats are back to back in UNIT, and there are 4 stats
	rep movsb

	mgetUnitField unitOffset, maxHealth
	mov ecx, 0
	.WHILE (ecx <= 3)			; go through every stat the unit has
		push eax				; save the unit's starting stats address
		mov eax, 7				; get a range of 7 numbers
		call RandomRange
		sub eax, 3				; forces the range result -3 to +3
		mov dl, al				; save result

		pop eax
		add BYTE PTR [eax + ecx], dl	; change stat by number drawn
		inc ecx
	.ENDW

	mGetUnitField unitOffset, maxHealth
	mov dl, BYTE PTR [eax]		; gets newly set max health
	mGetUnitField unitOffset, curHealth
	mov BYTE PTR [eax], dl		; initializes current health to new max health
	ret
SetStats ENDP

; ------------------------------
SetRole PROC USES eax edx ecx esi edi, unitOffset:DWORD
; Takes the unit whose role name will be set
; Places role name in role field of unit based on their roleID
; ------------------------------
	mGetUnitField unitOffset, roleID
	mov dl, BYTE PTR [eax]		; gets this unit's roleID
	.IF (dl == WARRIOR)			; puts in esi the corresponding name for each of the classes
		mov esi, OFFSET warriorName
	.ELSEIF (dl == ARCHER)
		mov esi, OFFSET archerName
	.ELSEIF (dl == KNIGHT)
		mov esi, OFFSET knightName
	.ELSE						; failsafe, puts no role
		mov esi, OFFSET noRoleName
	.ENDIF

	mGetUnitField unitOffset, role
	mov edi, eax				; puts the destination for the role name
	mov	ecx, 11					; size of name buffers

	INVOKE SetStats, unitOffset	; when role is changed, update stats
	rep movsb
	ret
SetRole ENDP

; ------------------------------
CreateUnit PROC USES eax edx ecx esi edi, nameOffset:DWORD, role:BYTE
; Takes a name and roleID
; Creates a new instance of a unit with its data in baseUnit
; ------------------------------
	mov esi, nameOffset
	mov edi, OFFSET baseUnit
	mov ecx, 11				; size of name buffers
	rep movsb				; moves the name into the baseUnit name

	mGetUnitField OFFSET baseUnit, roleID
	mov dl, role			; saves given role
	mov BYTE PTR [eax], dl	; assigns roleID to unit
	INVOKE SetRole, ADDR baseUnit	; initializes its stats with new role
	ret
CreateUnit ENDP

; ------------------------------
MoveUnit PROC USES eax edx ecx esi edi, unitOffset:DWORD, team:BYTE, position:BYTE
; Takes a unit and the deisred team + position
; Copies all the unit's data to the team slot and assigns it the team and pos fields
; ------------------------------
	mov dl, position
	mGetUnitField unitOffset, pos
	mov BYTE PTR [eax], dl			; assign new position value
	mov dl, team
	mGetUnitField unitOffset, team
	mov BYTE PTR [eax], dl			; assign new team value

	mov esi, unitOffset				; move data from object instance
	.IF (dl == ALLY)				; places unit in ally team offset
		lea edi, allies
	.ELSEIF (dl == ENEMY)			; places unit in enemy team offset
		lea edi, enemies
	.ENDIF
	mov ecx, 0						; clear ecx
	mov cl, position				; iterate for once for each position 
	IncreaseOffset:
		add edi, SIZEOF UNIT		; skip one unit in the team position
		loop IncreaseOffset

	mov ecx, SIZEOF UNIT			; copy all of unit's fields
	rep movsb						; copy unit to place in team
	ret
MoveUnit ENDP
END