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
	debugstr db "debug"
	message db 256 DUP(?)
	commandLine dd ?
	result_integral dd 0
	h dd 1;ширина отрезка; width of the rectangle
	XX1 dd ?
	XX2 dd ?
	AA dd ?
	BB dd ?

macro show_result{
	mov [result_integral], esi
	invoke sprintf, message,  "The calculated integral is %d",[result_integral]
	invoke MessageBox, 0, message, "Result", MB_OK
	invoke ExitProcess, 0
}
macro show_help{
      invoke MessageBox, 0,"Usage: in cmd> filename [a] [b] [x1] [x2] X1 != X2, A and B != 0", "Help", MB_OK
      invoke ExitProcess, 0
}
macro check_collect_input{

     mov eax, [AA]
     mov ebx, [BB]
     mov ebx, [XX1]
    ; invoke MessageBox, 0, launchstr, "Welcome", MB_OK
     cmp ebx,[XX2];проверка x1 = x2
     jge end_help; x1 >= x2



     OR eax, [BB];Проверка а и b на ноль
     cmp eax, 0
     je end_help
}
macro input{
	cinvoke GetCommandLine
	mov [commandLine], eax
	cinvoke sscanf,[commandLine], '%*s %d %d %d %d', AA,BB,XX1,XX2
	invoke sprintf, message,  "Params are a = %d; b = %d; X1 = %d ; X2 = %d ;",[AA],[BB], [XX1],[XX2]
	invoke MessageBox, 0, message, "Your input params", MB_OK

}

.code
    start:
	invoke MessageBox, 0, launchstr, "Welcome", MB_OK  ;launch the start welcome window; запускаем окно приветствия
	input
	check_collect_input

	;main section
	;edx = x1
	;while xx1 < xx2
	mov esi, 0
	mov ebx, [XX1]
	start_cycle:

		 cmp ebx,[XX2]
		 jge cycle_exit ;check if cycle is over


		 ;previous x1
		 mov edi, ebx
		 imul edi, ebx
		 imul edi, ebx
		 imul edi, [BB];*b
		 add edi, [AA];  = a+b*x^3
		 ;calculated f for prev x

		 ; mov [h], edi
		;  invoke sprintf, message,  "The edi is %d",[h]
		;  invoke MessageBox, 0, message, "res", MB_OK

		 inc ebx ;increment ebx

		 mov ebp, ebx
		 imul ebp, ebx
		 imul ebp, ebx
		 imul ebp,[BB];*b
		 add ebp, [AA];  = a+b*x^3

		 cmp edi,ebp
		 jle add_left

		 add_right:
			add  esi, ebp;added right value
			jmp start_cycle
		 add_left:
			add  esi, edi;added left value
			jmp start_cycle
	cycle_exit:
	show_result

	end_help:;метка перехода на вызов помощи при неправильных аргументах
		show_help






