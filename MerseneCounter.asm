; HSE 181, Num. 9: Armen Matevosyan
; This is an app for counting the Mersene numbers until given natural number
; The number is passed by commandline arguments, and if it's correct than programm count the specified numbers
; If the passed arguments are invalid than the message will be shown with required information

format	PE Console ; app's format
include 'C:\FASM\INCLUDE\WIN32AX.INC' ; WIN32AX.INC location

entry main ; Entry point of programm

section '.data' data readable writeable ; Section for storing data

	endl FIX 10, 13 ; New line character

	; Fields required for getting commandline arguments from the app
	argc dd ? ; argc
	argv dd ? ; argv
	env dd ?  ; env

	; User fields for output
	str_format  DB	"Entered number = %d , Count of Mersene's numbers = %d",0 ; Format of main output
	str_buffer  DB	256 dup (0) ; String buffer for mesasgebox output
	mb_title    db	"HSE 181, Num. 9: Armen Matevosyan", 0 ; Messagebox Title

	erromsg     db	"Count of args is not correct!!!",0
	errmsg	    db	"Entered not valid natrual number!!!", 0
	usagestr DB "Usage: MerseneCounter.exe [<OPTIONS>] <Natural Number>", endl, "Options:", endl, "-h, -?   show help message", endl, 0

	; User fields
	answer DD 0 ; Answer
	current DD 0 ; Current number
	num DD 0 ; Entered number


section '.text' code readable executable ; Section of code

; Main
proc main

	; Getting command line arguments
	invoke GetCommandLine
	cinvoke __getmainargs,argc,argv,env,0 ; storing info from command line to argc, argv, env
	cmp [argc],2 ; checking the count of args, must be 2 as the first argument is the path to the app
	jne .erro ; case when count is not 2
	mov esi,[argv] ; storing to argv

	mov EAX, [esi+4] ; moving to EAX
	cmp byte [EAX + 0], 2Dh ; EAX[0] == '-'
	je .check_help ; checking for help option

	mov edi, [esi+4] ; moving to edi
	call atoi ; calling atoi to convert string to integer
	mov [num], eax ; setting num the value of atoi

	cmp [num], 0; checks for not valid number or not natural one
	jng .err ; case when not valid number

	push [num]; pushing num for using with getcount
	call getcount ;Getting count of Mersene numbers

	call show_info ; showing ansers and other information
	jmp .finish; finishing app
endp

.check_help:
	cmp byte [EAX + 1], 68h ; EAX[1] == 'h'
	je .help ; shows help
	cmp byte [EAX + 1], 3Fh ; EAX[1] == '?'
	je .help ; shows help
	jmp .err

; Finishing our programm
.finish:
	invoke ExitProcess,0 ; ends program

; Case when not correct count of arguments
.erro:
	call show_erro
	jmp .finish ; finishs app

; Case when invalid passed argument
.err:
	call show_err
	jmp .finish ; finishs app
.help:
	call show_help
	jmp .finish

; Converts string to integer
proc atoi
	enter 0, 0
	mov eax, 0		; Set initial total to 0

	convert:
		movzx esi, byte [edi]	; Get the current character
		test esi, esi		; Check for \0
		je done

		cmp esi, 48		; Anything less than 0 is invalid
		jl error

		cmp esi, 57		; Anything greater than 9 is invalid
		jg error

		sub esi, 48		; Convert from ASCII to decimal
		imul eax, 10		; Multiply total by 10
		add eax, esi		; Add current digit to total

		inc edi 		; Get the address of the next character
		jmp convert

	error:
		mov eax, -1		; Return -1 on error
	done:
		leave
		ret			; Return total or error code
endp

proc getcount ; Gets Mersene numbers count not higher than num
	enter 16, 0
	mov	[current], 1 ; Set current to 1
	mov	[answer], 0 ; Set answer to 0
	inc	[num] ; Incrementing num by 1

	mov eax, [current]
	cmp eax, [num] ; Comparing current and num
	jg L2 ; entering loop with condition above

	L3:
		inc [answer] ; incrementing answer
		shl eax, 1 ; multiplying by 2
		cmp eax, [num] ; comparing current and num
		jle L3 ; ending function

		L2: ; function end point
		    dec [answer] ; Decrement answer as my count plus 1
		    dec [num] ; Decrement num as we incremented it here
		    mov eax, [answer] ; move answer to eax, can be ignored
		    leave
		    ret
endp

; Shows help message
proc show_help
	enter 0, 0
	invoke MessageBox, 0, usagestr, "Help", MB_OK
	leave
	ret
endp

; Shows error when invalid argument were passed
proc show_err
	enter 0, 0
	invoke MessageBox, 0, usagestr, errmsg, MB_OK
	leave
	ret
endp

; Shows error when count of passed arguments is not valid
proc show_erro
	enter 0, 0
	invoke MessageBox, 0, usagestr, erromsg, MB_OK
	leave
	ret
endp

; Show results and other information
proc show_info
	enter 0, 0
	invoke	wsprintf,str_buffer, str_format, [num], [answer]; getting correct buffer for MessageBox to show in
	invoke	MessageBox,0,str_buffer, mb_title,MB_OK ; Showing messagebox
	leave
	ret
endp

section '.idata' import data readable ; section for imports
	library user32,'user32.dll',kernel32,'kernel32.dll',msvcrt,'msvcrt.dll',shell32,'shell32.dll'

	include 'C:\FASM\INCLUDE\API\USER32.INC'
	include 'C:\FASM\INCLUDE\API\KERNEL32.INC'
	include 'C:\FASM\INCLUDE\API\SHELL32.INC'

	import msvcrt,\__getmainargs,'__getmainargs'

