format		PE console 4.0						; ?????????? ??????????.
entry start						      ; ????? ?????
include "C:/TheGreatestProjectsOfMyLife/Assembler/fasmw17121/INCLUDE/win32ax.inc"

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



import msvcrt,\
	 sprintf, 'sprintf', sscanf, 'sscanf'

.data
	endl FIX 10, 13 ;endline \n for strings; перенос строки
	launchstr db "This program will calculate definite integral a+b*x^3 on [x1;x2]",endl,"using the method of rectangles(width = 1)",endl, "Made by Plyusch Evgenii, BSE181_2, 2019",0
	message db 256 DUP(?)

	commandLine dd ?
	result_integral dd 0
	h dd 1;ширина отрезка; width of the rectangle
	X1 dd ?
	X2 dd ?
	AA dd ?
	BB dd ?

macro show_result{
	invoke sprintf, message,  "The calculated integral is %d",[result_integral];result_integral
	invoke MessageBox, 0, message, "Result", MB_OK
	invoke ExitProcess, 0
}
macro show_help{
       invoke MessageBox, 0,"Usage: in cmd> filename [a] [b] [x1] [x2]", "Help", MB_OK
       invoke ExitProcess, 0
}

macro check_input{

}

.code
    start:
	invoke MessageBox, 0, launchstr, "Welcome", MB_OK  ;launch the start welcome window; запускаем окно приветствия
	cinvoke GetCommandLine
	mov [commandLine], eax
	cinvoke sscanf,[commandLine], '%*s %d %d %d %d', AA,BB,X1,X2
	invoke sprintf, message,  "Params are %d %d %d %d",[AA],[BB], [X1],[X2];result_integral
	invoke MessageBox, 0, message, "Welcome", MB_OK
	show_help

	;cinvoke GetCommandLine
       ; mov [commandLine], eax


	show_result








