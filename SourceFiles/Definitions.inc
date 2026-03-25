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