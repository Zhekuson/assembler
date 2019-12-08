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
	res1 dd 1
	res2 dd 1
	count dd 1
	commandLine dd ?
	result_integral dd 0
	h dd 1;ширина отрезка; width of the rectangle
	XX1 dd ?
	XX2 dd ?
	AA dd ?
	BB dd ?

macro show_result{
	invoke sprintf, message,  "The calculated integral is %d",[result_integral];result_integral
	invoke MessageBox, 0, message, "Result", MB_OK
	invoke ExitProcess, 0
}
macro show_help{
      invoke MessageBox, 0,"Usage: in cmd> filename [a] [b] [x1] [x2] X1 != X2, A and B != 0", "Help", MB_OK
      invoke ExitProcess, 0
}
macro check_collect_input{

    ; mov eax, [AA]
    ; mov ebx, [BB]
     mov edx, [XX1]
     cmp edx, XX2;проверка x1 = x2
     jge end_help; x1 >= x2
     OR eax, ebx;Проверка а и b на ноль
     cmp eax, 0
     je end_help
     mov eax, [AA]
}
macro input{
	cinvoke GetCommandLine
	mov [commandLine], eax
	cinvoke sscanf,[commandLine], '%*s %d %d %d %d', AA,BB,XX1,XX2
	invoke sprintf, message,  "Params are a = %d; b = %d; X1 = %d; X2 = %d;",[AA],[BB], [XX1],[XX2]
	invoke MessageBox, 0, message, "Your input params", MB_OK

}
proc degree3;возведение в 3 степень, результат в bp
     push bp
     mul bp
endp

.code
    start:
	invoke MessageBox, 0, launchstr, "Welcome", MB_OK  ;launch the start welcome window; запускаем окно приветствия
	input
	check_collect_input
	;main section
	;eax = a, ebx = b, edx = x1
	;while xx1 < xx2
	start_cycle:
		 cmp edx, [XX2]
		 jg cycle_exit

		 mov ecx, edx; ecx = previous x1
		 inc edx
		 mov eax,[ecx]
		 mul eax, ecx


		 jmp start_cycle
	cycle_exit:



	end_help:;метка перехода на вызов помощи при неправильных аргументах
		show_help

	;cinvoke GetCommandLine
       ; mov [commandLine], eax


	show_result








