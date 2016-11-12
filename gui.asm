.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include gdi32.inc
includelib gdi32.lib

IDA_MAIN	equ	2000h
IDM_MAIN	equ	2000h
IDM_EXIT	equ	2011h
IDM_AVERAGE	equ	2021h
IDM_SORT	equ	2022h
IDM_LIST	equ	2023h
IDM_ABOUT	equ	2031h

TEXT_HEIGHT	equ 20
TEXT_WIDTH equ 80
NAME_WIDTH equ 100
WIN_WIDTH equ 800
WIN_HEIGHT equ 300

DRAWTEXT macro szStr
	invoke DrawText, @hDC, addr szStr, -1, addr @stRect, DT_LEFT or DT_VCENTER
endm

DRAWTEXTCENTER macro szStr
	invoke DrawText, @hDC, addr szStr, -1, addr @stRect, DT_LEFT or DT_VCENTER or DT_CENTER
endm

MOVRECTDOWN macro
	add @stRect.top, TEXT_HEIGHT
	add @stRect.bottom, TEXT_HEIGHT
	mov @stRect.left, 20
	mov @stRect.right, 20 + NAME_WIDTH
endm

MOVRECTRIGHT macro
	add @stRect.left, TEXT_WIDTH
	add @stRect.right, TEXT_WIDTH
endm

stStu struct
	szName db 10 dup(0)
	scChinese db 0
	scMath db 0
	scEnglish db 0
	scAverage db 0
	grade db 0
stStu ends

.data
	stInfo 	stStu <'zhangsan', 100, 85, 80, ,>
			stStu <'lisi', 80, 100, 70, ,>
			stStu <'wangwu', 70, 60, 80, ,>
			stStu <'xuxiaohua', 40, 55, 61, ,>
			stStu <'jiawenbo', 85, 95, 96, ,>
	bAveCalced db 0
	bListDrawn db 0
.data?
	hInstance dd ?
	hWinMain  dd ?
	hMenu     dd ?
.const
	szClassName db 'First Window', 0
	szCaptionMain db 'First Window', 0
	szMessage db 'CS1402贾文波', 0
	szList db 'List', 0
	szFormatNum db '%d', 0
	szFormatChar db '%c', 0 
	szHName db 'Name', 0
	szHChinese db 'Chinese', 0
	szHMath db 'Math', 0 
	szHEnglish db 'English', 0
	szHAverage db 'Average', 0
	szHGrade db 'Grade', 0
	szCalcAve db '请先计算平均值，再进行排序！', 0 
	dHeaderAdr dd offset szHChinese, offset szHMath, szHEnglish, szHAverage, szHGrade
.code

_Quit proc
	invoke DestroyWindow, hWinMain
	invoke PostQuitMessage, NULL
	ret
_Quit endp

CopyMemory proc uses esi edi , dest : dword, source : dword, cpLen : dword
	mov edi, dest
	mov esi, source
	mov ecx, cpLen
	
	.while ecx > 0
		mov al, [esi + ecx - 1]
		mov [edi + ecx - 1], al
		dec ecx
	.endw
	ret 
CopyMemory endp

_Sort proc uses esi edi
	local @stTemp : stStu
	local @dFinalAdr, @dLastAdr
	
	mov @dFinalAdr, offset bAveCalced
	mov @dLastAdr, offset bAveCalced - sizeof stStu
	
	assume esi : ptr stStu
	assume edi : ptr stStu
	
	.if bAveCalced == 0
		invoke MessageBox, hWinMain, addr szCalcAve, addr szCaptionMain, MB_OK or MB_ICONERROR
		jmp exitSort
	.endif
	
	mov esi, offset stInfo
	.while esi < @dLastAdr
		mov edi, esi
		add edi, sizeof stStu
		
		.while edi < @dFinalAdr
			mov al, [esi].scAverage
			.if al < [edi].scAverage
				invoke CopyMemory, addr @stTemp, esi, sizeof stStu
				invoke CopyMemory, esi, edi, sizeof stStu
				invoke CopyMemory, edi, addr @stTemp, sizeof stStu
			.endif
			
			add edi, sizeof stStu
		.endw
		add esi, sizeof stStu
	.endw
exitSort:
	xor eax, eax
	ret
_Sort endp

_Average proc uses esi ebx ecx edx
	mov esi, offset stInfo
	assume esi : ptr stStu
	mov ecx, 5
	mov bAveCalced, 1
	
	.while ecx > 0
		movzx dx, [esi].scChinese
		imul dx, 4
		movzx ax, [esi].scMath
		imul ax, 2
		add ax, dx
		movzx bx, [esi].scEnglish
		add ax, bx
		mov bl, 7
		div bl
		mov [esi].scAverage, al
		
		.if al >= 90
			mov [esi].grade, 'A'
		.elseif al >= 80
			mov [esi].grade, 'B'
		.elseif al >= 70
			mov [esi].grade, 'C'
		.elseif al >= 60
			mov [esi].grade, 'D'
		.else
			mov [esi].grade, 'F'
		.endif
		
		add esi, sizeof stStu
		dec ecx
	.endw
	xor eax, eax
	ret
_Average endp

_List proc uses ebx ecx esi edi @hDC : dword
	local @szBuf[20]:byte

	local @stRect : RECT
	local @hPen
	
	mov @stRect.left, 20
	mov @stRect.top, TEXT_HEIGHT
	mov @stRect.bottom, TEXT_HEIGHT * 2
	mov @stRect.right, 600
	
	invoke CreatePen, PS_SOLID, 3, 0ffh				;创建画笔
	invoke SelectObject, @hDC, eax
	mov @hPen, eax
	invoke SetTextColor, @hDC, 0ffh					;设置文本颜色
	
	DRAWTEXT szList
	MOVRECTDOWN
	
	DRAWTEXT szHName
	mov @stRect.left, 20 + NAME_WIDTH
	mov @stRect.right, 20 + NAME_WIDTH + TEXT_WIDTH
	mov ebx, 0
	mov esi, offset dHeaderAdr
	
	.while ebx < 5
		invoke DrawText, @hDC, dword ptr [esi], -1, addr @stRect, DT_LEFT or DT_VCENTER or DT_CENTER
		add esi, 4
		inc ebx
		MOVRECTRIGHT
	.endw
	MOVRECTDOWN
	
	invoke MoveToEx, @hDC, 0, 70, NULL								;画线
	invoke LineTo, @hDC, 20 + NAME_WIDTH + TEXT_WIDTH * 5, 70
	
	mov ecx, 5
	mov esi, offset stInfo
	assume esi : ptr stStu

	.while ecx > 0
		MOVRECTDOWN
		pushad
		DRAWTEXT [esi].szName
		
		mov @stRect.left, 20 + NAME_WIDTH
		mov @stRect.right, 20 + NAME_WIDTH + TEXT_WIDTH
		
		xor ebx, ebx
		lea edi, [esi].scChinese
		
		.while ebx < 3
			pushad
			invoke wsprintf, addr @szBuf, addr szFormatNum, byte ptr [edi]
			DRAWTEXTCENTER @szBuf
			MOVRECTRIGHT
			popad
			inc ebx
			inc edi
		.endw
		
		.if bAveCalced == 1
			invoke wsprintf, addr @szBuf, addr szFormatNum, [esi].scAverage
			DRAWTEXTCENTER @szBuf
			MOVRECTRIGHT
			invoke wsprintf, addr @szBuf, addr szFormatChar, [esi].grade
			DRAWTEXTCENTER @szBuf
		.endif
		
		popad
		add esi, sizeof stStu
		dec ecx
	.endw
	
	invoke DeleteObject, @hPen				;清理工作
	ret
_List endp

_ProcWinMain proc uses ebx edi esi hWnd, uMsg, wParam, lParam	
	local @stPaint : PAINTSTRUCT
	mov eax, uMsg
	
	.if eax == WM_COMMAND
		mov eax, wParam
		movzx eax, ax
		.if eax == IDM_EXIT
			call _Quit
		.elseif eax == IDM_ABOUT
			invoke MessageBox, hWnd, addr szMessage, addr szCaptionMain, MB_OK or MB_ICONINFORMATION
		.elseif eax == IDM_LIST
			mov bListDrawn, 1 
			invoke InvalidateRect, hWnd, NULL, TRUE
		.elseif eax == IDM_AVERAGE
			call _Average
		.elseif eax == IDM_SORT
			call _Sort
		.endif
	.elseif eax == WM_CLOSE
		call _Quit
	.elseif eax == WM_PAINT && bListDrawn == 1
		invoke BeginPaint, hWnd, addr @stPaint
		invoke _List, eax
		invoke EndPaint, hWnd, addr @stPaint
		call _List
	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.endif
	
	xor eax, eax
	ret
_ProcWinMain endp

_WinMain proc
	local @stWndClass:WNDCLASSEX
	local @stMsg:MSG
	local @hAccelerator
	
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	
	invoke LoadMenu, hInstance, IDM_MAIN
	mov hMenu, eax
	invoke LoadAccelerators, hInstance, IDA_MAIN
	mov @hAccelerator, eax
	
	invoke RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
	push hInstance
	
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize, sizeof WNDCLASSEX
	mov @stWndClass.style, 0
	mov @stWndClass.lpfnWndProc, offset _ProcWinMain
	mov @stWndClass.hbrBackground, COLOR_WINDOW + 1
	mov @stWndClass.lpszClassName, offset szClassName
	invoke RegisterClassEx, addr @stWndClass
	
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szClassName, offset szCaptionMain,\
		   WS_OVERLAPPEDWINDOW , 100, 100, WIN_WIDTH, WIN_HEIGHT, NULL, hMenu, hInstance, NULL
	mov hWinMain, eax
	invoke ShowWindow, hWinMain, SW_SHOWNORMAL
	invoke UpdateWindow, hWinMain
	
	.while TRUE
		invoke GetMessage, addr @stMsg, NULL, 0, 0
		.break .if eax == 0
		invoke TranslateAccelerator, hWinMain, @hAccelerator, addr @stMsg
		.if eax == 0
			invoke TranslateMessage, addr @stMsg
			invoke DispatchMessage, addr @stMsg
		.endif
	.endw
	ret
_WinMain endp

start:
	call _WinMain
	invoke ExitProcess, NULL
end start
