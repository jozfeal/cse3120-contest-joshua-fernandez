BOXROW EQU 24	; start of player's input box
; rows that the units are placed in
ENEMYROW EQU 8
ALLYROW EQU 16
UNITCOL EQU 26 ; column numbers for each of the units

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
ESCAPE EQU 01h	; keyboard scan code for Escape key
