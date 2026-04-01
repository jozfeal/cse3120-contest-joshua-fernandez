OPTION PROC:PUBLIC ; default option for methods
ResetScreen PROTO
ResetBox PROTO
WriteName PROTO, unitOffset:DWORD
ColorNumber PROTO, color:DWORD, number:DWORD
PrintUnits PROTO

EXTERNDEF dashedLine:BYTE

; prints the dashed line separating game box from player input box
mPrintLine MACRO
	mGotoxy 0, BOXROW - 1
	mov edx, OFFSET dashedLine
	call WriteString
ENDM