.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.code
main PROC
	mov eax,5 ; move 5 to the eax register
	add eax,6 ; add 6 to the eax register

INVOKE ExitProcess,0
main ENDP
END main