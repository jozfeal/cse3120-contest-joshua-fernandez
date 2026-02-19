;.386
;.model flat,stdcall
;.stack 4096
INCLUDE Irvine32.inc

ExitProcess PROTO, dwExitCode:DWORD
Draw PROTO

.code
Main PROC
	call Draw
	INVOKE ExitProcess,0
Main ENDP

END Main