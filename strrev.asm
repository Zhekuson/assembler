format	PE GUI 4.0
include "C:/TheGreatestProjectsOfMyLife/Assembler/fasmw17121/INCLUDE/win32ax.inc"

.data

endl FIX 10, 13
usagestr DB "Usage: strrev.exe [<OPTIONS>] <STRING...>", endl, "Options:", endl, "-h, -?    show this message and exit", 0
wordfmt DB "%255s", 0
wordlenfmt DB "%*s%n ", 0
strnoarguments DB "No arguments", 0
strunknownoption DB "Unknown option: %s", 0
fmtbuf DB 256 dup(0)
mainstr DB 256 dup(0)
curarg DB 256 dup(0)
cmdline DD 0

.code
macro show_num n {
	push EAX
	push ECX
	push EDX
	invoke wsprintf, fmtbuf, "%d", n
	add ESP, 12
	invoke MessageBox, 0, fmtbuf, "Number shown", MB_OK
	pop EDX
	pop ECX
	pop EAX
}

macro show_char n {
	push EAX
	push ECX
	push EDX
	xor EAX, EAX
	mov AL, n
	invoke wsprintf, fmtbuf, "%x '%c'", EAX, EAX
	add ESP, 16
	invoke MessageBox, 0, fmtbuf, "Character shown", MB_OK
	pop EDX
	pop ECX
	pop EAX
}

start:
cinvoke GetCommandLine
mov [cmdline], EAX
call skip_next_arg

call peek_next_arg
cmp EAX, 0
jne has_arguments

push 0
push strnoarguments
call show_error
add ESP, 8

invoke ExitProcess, 1

has_arguments:
mov EAX, curarg

cmp byte [EAX + 0], 2Dh ; EAX[0] == '-'
jne not_option
cmp byte [EAX + 2], 00h ; EAX[2] == '\0'
jne not_option
cmp byte [EAX + 1], 68h ; EAX[1] == 'h'
je show_help_success
cmp byte [EAX + 1], 3Fh ; EAX[1] == '?'
je show_help_success

push EAX
push strunknownoption
call show_error
add ESP, 8

invoke ExitProcess, 2

show_help_success:

call show_help

invoke ExitProcess, 0

not_option:

push [cmdline]
call str_len
add ESP, 4

push EAX
push [cmdline]
push mainstr
call mem_copy
add ESP, 12

invoke MessageBox, 0, mainstr, "Original string:", MB_OK

push mainstr
call str_rev
add ESP, 4

invoke MessageBox, 0, mainstr, "Reversed string:", MB_OK

invoke ExitProcess, 0

proc skip_next_arg
	n EQU dword [EBP + 8]
	nptr EQU dword [EBP - 4]

	enter 4, 0
	mov nptr, EBP
	add nptr, 8

	cinvoke sscanf, [cmdline], wordlenfmt, nptr
	
	cmp EAX, 0
	jge skip_next_arg_success
	mov EAX, 0
	leave
	ret
	
	skip_next_arg_success:
	mov EDX, [cmdline]
	add EDX, n
	mov [cmdline], EDX

	mov EAX, 1
	leave
	ret
	
	restore n
	restore nptr
endp

proc peek_next_arg
	enter 0, 0
	
	cinvoke sscanf, [cmdline], wordfmt, curarg
	
	cmp EAX, 0
	jge peek_next_arg_success
	mov EAX, 0
	leave
	ret
	
	peek_next_arg_success:
	mov EAX, 1
	leave
	ret
endp

proc show_error
	fmt EQU dword [EBP + 8]
	fmtarg EQU dword [EBP + 12]; optional argument
	
	enter 0, 0
	invoke wsprintf, fmtbuf, fmt, fmtarg
	invoke MessageBox, 0, fmtbuf, "Error", MB_OK
	call show_help
	leave
	ret
	
	restore fmtarg
	restore fmt
endp

proc show_help
	enter 0, 0
	invoke MessageBox, 0, usagestr, "Help", MB_OK
	leave
	ret
endp

proc str_len
	str EQU dword [EBP + 8]
	
	enter 0, 0
	
	push EDI ; Registers EAX, ECX, and EDX are caller-saved, and the rest are callee-saved. (cdecl)
	push ESI
	
	cld
	mov EDI, str
	mov ESI, EDI
	mov ECX, 256d ; Maximum length
	mov AL, 0
	repne scasb
	dec EDI
	sub EDI, ESI
	mov EAX, EDI
	
	pop ESI
	pop EDI
	
	leave
	ret
	
	restore str
endp

proc mem_copy
	dest EQU dword [EBP + 8]
	src EQU dword [EBP + 12]
	length EQU dword [EBP + 16]
	
	enter 0, 0
	push EDI
	push ESI
	
	mov EDI, dest
	mov ESI, src
	mov ECX, length
	cld; mov DF, 0

	mem_copy_loop:
	cmp ECX, 0
	jg mem_copy_loop_cond
	
	pop ESI
	pop EDI
	leave
	ret
	mem_copy_loop_cond:; while(length > 0) {
	movsb; *(dest++) = *(src++);
	dec ECX; length--;
	jmp mem_copy_loop; }
	
	restore dest
	restore src
	restore length
endp

proc str_rev
	str EQU dword [EBP + 8]
	
	enter 0, 0
	
	push str
	call str_len
	add ESP, 4
	
	dec EAX
	push EAX
	push str
	call mem_rev
	
	leave
	ret
	
	restore str
endp

proc mem_rev
	memstart EQU dword [EBP + 8]
	lastIndex EQU dword [EBP + 12]
	
	enter 0, 0
	
	mov EAX, memstart
	mov ECX, lastIndex
	add ECX, EAX
	
	mem_rev_loop:
	
	cmp EAX, ECX
	jge mem_rev_end
	
	mov DL, [EAX]
	mov DH, [ECX]
	
	mov [EAX], DH
	mov [ECX], DL
	
	inc EAX
	dec ECX
	
	jmp mem_rev_loop
	
	mem_rev_end:
	leave
	ret
	
	restore lastIndex
	restore memstart
endp


;Same as ".end start", but also with msvcrt
;{
entry start

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
		user32,'USER32.DLL',\
		gdi32,'GDI32.DLL',\
		advapi32,'ADVAPI32.DLL',\
		comctl32,'COMCTL32.DLL',\
		comdlg32,'COMDLG32.DLL',\
		shell32,'SHELL32.DLL',\
		wsock32,'WSOCK32.DLL',\
		msvcrt,'MSVCRT.DLL'

		import_kernel32
		import_user32
		import_gdi32
		import_advapi32
		import_comctl32
		import_comdlg32
		import_shell32
		import_wsock32

		all_api  
;}


import msvcrt, \
	   sscanf,  'sscanf'
