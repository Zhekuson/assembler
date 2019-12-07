format PE GUI 4.0

entry start

include 'win32ax.inc'

section '.idata' import data readable

	library user32,'USER32.DLL',\
		msvcrt, 'MSVCRT.DLL',\
		kernel32, 'KERNEL32.DLL',\
		shell32, 'SHELL32.DLL'
 
	import user32,\
	       MessageBox, 'MessageBoxA'
 
	import msvcrt,\
	       sprintf, 'sprintf', sscanf, 'sscanf'
 
	import kernel32,\
	       ExitProcess, 'ExitProcess',\
	       GetCommandLine, 'GetCommandLineA'

.data
	commandLine dd ?
	n dd 0
	string db 256 DUP(?)

macro show_num n {
	push EAX
	push ECX
	push EDX
	invoke sprintf, string, "%d", n
	add ESP, 12
	invoke MessageBox, 0, string, "Number shown", MB_OK
	pop EDX
	pop ECX
	pop EAX
}


.code
	start:
		cinvoke GetCommandLine
		mov [commandLine], eax
		cinvoke sscanf,[commandLine],'%*s %d', n
		cmp eax, 0
		je help

		mov ebx, 0 ;переменная-счётчик количества найденных подпоследовательностей '110'
		mov ecx, 0 ;переменная, хранящая количество предыдущих битов, удовлетворяющих нашему условию
		mov edx, 10000000000000000000000000000000b ;переменная для итерирования по битовому представлению числа n
		jmp body

		body:
			cmp edx, 0
			je output

			mov eax, [n]
			and eax, edx

			cmp ecx, 2
			je check0
			jmp check1

			check0:
				cmp eax, 0
				je do0
				mov ecx, 0
				jmp fin
				do0:
					mov ecx, 0
					inc ebx
					jmp fin

			check1:
				cmp eax, 0
				jne do1
				mov ecx, 0
				jmp fin
				do1:
					inc ecx
					jmp fin

			fin:
				shr edx,1
				jmp body

		output:
			invoke sprintf, string, "The amount of '110' subsequences in %d: %d",[n],ebx
			invoke MessageBox, 0, string, "Success", MB_OK
			invoke ExitProcess, 0

		help:
			invoke MessageBox, 0, "After the path type an integer number from 0 to 2^32 - 1", "This program was developed by Alexander Serebrennikov, BSE181", MB_OK
			invoke ExitProcess,0