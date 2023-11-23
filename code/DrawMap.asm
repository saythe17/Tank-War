		.386
		.model		flat,stdcall
		option		casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		gdi32.inc
includelib	gdi32.lib
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib


;新增
include Comdlg32.inc
includelib Comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data
hInstance		dd	?
hWinMain		dd	?
bg				dd	?
completeWall	dd	?
wallMask		dd	?
ironWall		dd	?
homeBird		dd	?
noneWall		dd	?
htank_left		dd	?
htank_left2		dd	?
htank_lmask		dd	?
thing STRUCT
id	dd	?
x	dd	?
y	dd	?
w	dd	?
h	dd	?
rop	dd	?
thing ends
wallpix	STRUCT
x		dd	?
y		dd	?
wallpix	ends
;0：A空气	1：C红墙	2：I：铁墙	3：B：鸟	4：P：玩家1	5：Q：玩家2
;使用ID进行存储
draw_array	dd	100	dup (?) 
refergraph_array	thing	12 dup(<?,?,?,?,?,?>)
MouseClick	db	0
hitpoint POINT <>
subpoint POINT <>
tempthingmask	dd	?
tempthing		dd	?
tank1count		dd	0
tank2count		dd	0

stRect			RECT <150,100,1035,690>
printlist thing 1024 dup(<?,?,?,?,?,?>)
count			dd	0
wallpix_array	wallpix	100 dup(<?,?>)
mywParam WPARAM 100 dup(?)
wParamCount dword 0
butSave   dd ?
szButtonText    db     'Save',0
bmpBtnCl  db "BUTTON"
blnk2   db 0

szNewFile	db	MAX_PATH dup(?)
szsplit         db  '\map\.',0

		.const
szClassName		db	'MyClass', 0
szCaptionMain	db	'BIT-TankWar', 0
szText			db	'fightfight', 0
szCaption		 db '执行结果',0
szFilter db 'Text Files(*.txt)',0,'*.txt',0
szDefExt db 'txt',0
szSaveCaption db '请输入保存的文件名',0

walllen		dd	65
maplen		dd	10
szFileExt	db	'文本文件',0,'*.txt',0,0
szErrOpenFile	db	'无法打开源文件',0 
szErrCreateFile db	'无法创建新的文本文件!',0 
szSuccess	db	'文件转换成功，新的文本文件保存为',0dh,0ah,'*s',0 
szSuccessCap	db	 '提示',0 

text_CWall	db	'普通墙壁，可被击穿',0
text_IWall	db	'坚固墙壁，不可被击穿',0
text_NWall	db	'清除已画地图块',0
text_Player1	db	'玩家1',0
text_Player2	db	'玩家2',0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 Load
; 参数		：
; 功能		：		加载所用到的bmp图像
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Load		proc	uses eax ebx ecx edx esi edi 
	; 坦克
	
	invoke LoadBitmap, hInstance, 110
	mov bg,eax
	invoke LoadBitmap, hInstance, 115
	mov completeWall,eax
	invoke LoadBitmap, hInstance, 116
	mov wallMask,eax
	invoke LoadBitmap, hInstance, 122
	mov ironWall,eax
	invoke LoadBitmap, hInstance, 123
	mov homeBird,eax
	invoke LoadBitmap, hInstance, 124
	mov noneWall,eax
	invoke LoadBitmap, hInstance, 104
	mov htank_left, eax
	invoke LoadBitmap, hInstance, 105
	mov htank_left2,eax
	invoke LoadBitmap, hInstance, 106
	mov htank_lmask,eax
	ret
_Load endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _AddList
; 参数		：		id:dword,x:dword,y:dword,w:dword,h:dword,rop:dword
; 功能		：		将想要打印的bmp信息添加到printlist中
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_AddList	proc	uses eax ebx ecx edx esi edi id:dword,x:dword,y:dword,w:dword,h:dword,rop:dword
	.if count < 1024
		mov eax, count
		mov ecx, TYPE thing
		mul ecx
		mov ebx, offset printlist
		add ebx, eax
		mov eax, id
		mov (thing ptr [ebx]).id, eax
		mov eax, x
		mov (thing ptr [ebx]).x, eax
		mov eax, y
		mov (thing ptr [ebx]).y, eax
		mov eax, w
		mov (thing ptr [ebx]).w, eax
		mov eax, h
		mov (thing ptr [ebx]).h, eax
		mov eax, rop
		mov (thing ptr [ebx]).rop, eax
		inc count
	.endif
	ret
_AddList	endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _PrintMapRefer
; 参数		：		hdc1:dword,hdc2:dword
; 功能		：		将参考图标打印出来
; 作者		：		黄昱欣，高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_PrintMapRefer proc	uses eax ebx ecx edx esi edi hdc1:dword,hdc2:dword
	local	@bminfo:BITMAP

	invoke GetObject,bg,type @bminfo,addr @bminfo
	invoke SelectObject,hdc2,bg
	invoke StretchBlt,hdc1,0,0,1035,690,hdc2,0,0,@bminfo.bmWidth,@bminfo.bmHeight,SRCPAINT

	mov esi, 0
	mov edi, offset refergraph_array
	.while esi < 10
		invoke GetObject,(thing PTR [edi]).id,type @bminfo,addr @bminfo
		invoke SelectObject,hdc2,(thing PTR [edi]).id
		invoke StretchBlt,hdc1,(thing PTR [edi]).x,(thing PTR [edi]).y,(thing PTR [edi]).w,(thing PTR [edi]).h,hdc2,0,0,@bminfo.bmWidth,@bminfo.bmHeight,(thing PTR [edi]).rop
		inc esi
		add edi, TYPE thing
	.endw
	ret
_PrintMapRefer		endp



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Print
; 参数		：		
; 功能		：		将printlist中的全部打印
; 作者		：		黄昱欣，高乃珺，翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Print		proc	uses eax ebx ecx edx esi edi
	local	@stPs:PAINTSTRUCT
	local	hdc:dword 
	local	hdc1:dword
	local	hdc2:dword
	local	mDc:dword
	local	sbrush:dword
	local	hbitmap:dword
	local	@bminfo:BITMAP
	local   @stRect: RECT

	invoke BeginPaint, hWinMain, addr @stPs
	mov hdc,eax

	invoke CreateCompatibleDC,hdc
	mov hdc1,eax

	invoke CreateCompatibleDC,hdc1
	mov hdc2,eax
	;这部分相当于告诉电脑，缓冲区1的大小
	invoke CreateCompatibleBitmap,hdc,stRect.right,stRect.bottom
	mov hbitmap,eax
	
	invoke CreateCompatibleDC,hdc1	
	mov	mDc,eax

	invoke CreateSolidBrush,0ffffffh
	mov sbrush,eax
	
	invoke SelectObject,hdc1,hbitmap
	;设置成可变
	invoke SetStretchBltMode,hdc,HALFTONE
	invoke SetStretchBltMode,hdc1,HALFTONE
	invoke SelectObject,mDc,sbrush

	invoke _PrintMapRefer,hdc1,hdc2

	mov esi, 0
	mov edi, offset printlist
	.while esi < count
		invoke GetObject,(thing PTR [edi]).id,type @bminfo,addr @bminfo
		invoke SelectObject,hdc2,(thing PTR [edi]).id
		invoke StretchBlt,hdc1,(thing PTR [edi]).x,(thing PTR [edi]).y,(thing PTR [edi]).w,(thing PTR [edi]).h,hdc2,0,0,@bminfo.bmWidth,@bminfo.bmHeight,(thing PTR [edi]).rop
		inc esi
		add edi, TYPE thing
	.endw

	mov		@stRect.left,800
	mov		@stRect.top,70
	mov		@stRect.right,1000
	mov		@stRect.bottom,500
	invoke SetBkMode,hdc1,TRANSPARENT
	invoke SetBkColor,hdc1,00ffffffh
	invoke SetTextColor,hdc1,00ffffffh
	invoke DrawText,hdc1,addr text_CWall,-1,addr @stRect,DT_CENTER

	mov		@stRect.left,800
	mov		@stRect.top,170
	mov		@stRect.right,1000
	mov		@stRect.bottom,500
	invoke SetBkMode,hdc1,TRANSPARENT
	invoke SetBkColor,hdc1,00ffffffh
	invoke SetTextColor,hdc1,00ffffffh
	invoke DrawText,hdc1,addr text_IWall,-1,addr @stRect,DT_CENTER

	mov		@stRect.left,800
	mov		@stRect.top,270
	mov		@stRect.right,1000
	mov		@stRect.bottom,500
	invoke SetBkMode,hdc1,TRANSPARENT
	invoke SetBkColor,hdc1,00ffffffh
	invoke SetTextColor,hdc1,00ffffffh
	invoke DrawText,hdc1,addr text_NWall,-1,addr @stRect,DT_CENTER

	mov		@stRect.left,760
	mov		@stRect.top,480
	mov		@stRect.right,1000
	mov		@stRect.bottom,500
	invoke SetBkMode,hdc1,TRANSPARENT
	invoke SetBkColor,hdc1,00ffffffh
	invoke SetTextColor,hdc1,00ffffffh
	invoke DrawText,hdc1,addr text_Player1,-1,addr @stRect,DT_LEFT

	mov		@stRect.left,890
	mov		@stRect.top,480
	mov		@stRect.right,1000
	mov		@stRect.bottom,500
	invoke SetBkMode,hdc1,TRANSPARENT
	invoke SetBkColor,hdc1,00ffffffh
	invoke SetTextColor,hdc1,00ffffffh
	invoke DrawText,hdc1,addr text_Player2,-1,addr @stRect,DT_LEFT

	;将缓冲区1的内容复制到电脑上
	invoke StretchBlt,hdc,0,0,stRect.right,stRect.bottom,hdc1,0,0,stRect.right,stRect.bottom,SRCCOPY
	invoke DeleteDC,hbitmap
	invoke DeleteDC,hdc2
	invoke DeleteDC,hdc1
	invoke DeleteDC,hdc
	invoke EndPaint,hWinMain,addr @stPs
	;清空iteams数组
	mov count,0
	ret
_Print		endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _CheckWall
; 参数		：		xpix,ypix,walltype
; 功能		：		自动修正歪斜，并添加到array中
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CheckWall proc uses eax ebx ecx edx esi edi xpix,ypix,walltype
		.if xpix < 20 || xpix > 670 || ypix < 20 || ypix > 670
			ret
		.endif

		mov eax,walltype
		.if eax == htank_left
			mov eax,tank1count
			.if eax > 0
				ret
			.endif
			mov tank1count,1
		.elseif eax == htank_left2
			mov eax,tank2count
			.if eax > 0
				ret
			.endif
			mov tank2count,1
		.endif

		mov eax,xpix
		sub eax,20
		mov ebx,walllen
		xor edx,edx
		div ebx
		mov ecx,eax

		mov eax,ypix
		sub eax,20
		mov ebx,walllen
		xor edx,edx
		div ebx

		mov ebx,maplen
		mul ebx
		add eax,ecx
		mov ebx,TYPE dword
		mul ebx

		mov esi,offset draw_array
		add esi,eax
		mov eax,walltype
		.if eax == noneWall
			mov ebx,dword ptr[esi]
			.if ebx == htank_left
				mov tank1count,0
			.elseif ebx == htank_left2
				mov tank2count,0
			.endif
		.endif
		mov dword ptr[esi],eax

		ret
_CheckWall endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _PaintMap
; 参数		：		
; 功能		：		初始绘画地图
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

_PaintMap	proc	uses eax ebx ecx edx esi edi
;0：A空气	1：C红墙	2：I：铁墙	3：B：鸟	4：P：玩家1	5：Q：玩家2

		mov	esi,offset draw_array
		mov	edi,offset wallpix_array
		mov eax,maplen
		mov ecx,eax
		mul ecx
		mov ecx,eax
		.while ecx > 0
			mov edx,dword PTR[esi]
			.if edx == completeWall 
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, completeWall, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.elseif edx == ironWall
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, ironWall, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.elseif edx == homeBird
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, homeBird, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.elseif edx == htank_left
				invoke _AddList, htank_lmask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, htank_left, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.elseif edx == htank_left2
				invoke _AddList, htank_lmask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, htank_left2, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.endif
			add esi,4
			add edi,TYPE wallpix
			dec ecx
		.endw
		ret
_PaintMap	endp



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _InitMap
; 参数		：		
; 功能		：		根据地图文件初始化地图
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InitMapPix proc uses eax ebx ecx edx esi edi
		;初始化墙壁和图像像素位置关系
		mov	edi,offset wallpix_array
		xor ecx,ecx
		xor edx,edx
		mov edx,20
		.while	ecx<maplen
			xor eax,eax
			xor ebx,ebx
			mov ebx,20
			.while eax<maplen
				mov (wallpix PTR [edi]).x,ebx
				mov (wallpix PTR [edi]).y,edx
				inc eax
				add ebx,walllen
				add edi,TYPE wallpix
			.endw
			inc ecx
			add edx,walllen
		.endw
		ret
_InitMapPix	endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _InitBackground
; 参数		：		
; 功能		：		初始化参考图标数据
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InitBackground proc uses eax ebx ecx edx esi edi
		mov esi,offset refergraph_array

		;红墙参考
		mov eax,wallMask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,40
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,completeWall
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,40
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing

		mov eax,wallMask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,140
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,ironWall
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,140
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing


		mov eax,wallMask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,240
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,noneWall
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,240
		mov (thing PTR[esi]).w,80
		mov (thing PTR[esi]).h,80
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing

		mov eax,htank_lmask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,380
		mov (thing PTR[esi]).w,100
		mov (thing PTR[esi]).h,100
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,htank_left
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,720
		mov (thing PTR[esi]).y,380
		mov (thing PTR[esi]).w,100
		mov (thing PTR[esi]).h,100
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing

		mov eax,htank_lmask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,850
		mov (thing PTR[esi]).y,380
		mov (thing PTR[esi]).w,100
		mov (thing PTR[esi]).h,100
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,htank_left2
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,850
		mov (thing PTR[esi]).y,380
		mov (thing PTR[esi]).w,100
		mov (thing PTR[esi]).h,100
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing

		mov eax,wallMask
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,755
		mov (thing PTR[esi]).y,280
		mov (thing PTR[esi]).w,65
		mov (thing PTR[esi]).h,65
		mov (thing PTR[esi]).rop,SRCAND
		add esi,TYPE thing
		mov eax,homeBird
		mov (thing PTR[esi]).id,eax
		mov (thing PTR[esi]).x,755
		mov (thing PTR[esi]).y,280
		mov (thing PTR[esi]).w,65
		mov (thing PTR[esi]).h,65
		mov (thing PTR[esi]).rop,SRCPAINT
		add esi,TYPE thing

		ret
_InitBackground endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _IsRefer
; 参数		：		
; 功能		：		判断鼠标点击处是否是某一参考图标
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_IsRefer proc uses ebx ecx edx esi edi xpix,ypix
		xor eax,eax
		mov ecx,5

		mov esi,offset refergraph_array

		.while ecx > 0
			mov ebx,(thing PTR[esi]).x
			cmp ebx,xpix
			ja _IsReferJmp
			add ebx,(thing PTR[esi]).w
			cmp ebx,xpix
			jb _IsReferJmp
			mov ebx,(thing PTR[esi]).y
			cmp ebx,ypix
			ja _IsReferJmp
			add ebx,(thing PTR[esi]).h
			cmp ebx,ypix
			ja _IsReferEnd
_IsReferJmp:
			add esi,TYPE thing
			add esi,TYPE thing
			dec ecx
		.endw
		ret
_IsReferEnd:
		mov eax,esi
		ret
_IsRefer endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _SaveAs
; 参数		：		
; 功能		：		更改保存地图的路径
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SaveAs proc 
		local	@stOF:OPENFILENAME
		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF 
		invoke  GetCurrentDirectory,MAX_PATH,addr szNewFile

		mov		edi,offset szNewFile
		mov     edx,offset szsplit
        invoke	lstrcat,edi,edx  
		mov		@stOF.lStructSize,sizeof @stOF
		push    hWinMain
		pop		@stOF.hwndOwner
		mov		@stOF.lpstrFilter,offset szFilter
		mov		@stOF.lpstrFile,offset szNewFile 
		mov		@stOF.nMaxFile,MAX_PATH
		mov		@stOF.Flags,OFN_PATHMUSTEXIST
		mov		@stOF.lpstrDefExt,offset szDefExt 
		mov		@stOF.lpstrTitle,offset szSaveCaption 
		invoke	GetSaveFileName,addr @stOF 
		ret

_SaveAs	endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _WriteMap
; 参数		：		
; 功能		：		保存地图
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WriteMap proc uses ebx ecx edx esi edi
		local	@hFileNew,@dwBytesWrite
		local	@szBuffer:byte

		
		invoke _SaveAs
		.if eax ==0
				ret
		.endif

		invoke	CreateFile,addr szNewFile,GENERIC_WRITE,\
				FILE_SHARE_READ,\
				0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if		eax ==	INVALID_HANDLE_VALUE
		invoke MessageBox,hWinMain,addr szErrCreateFile,\
				NULL,MB_OK or MB_ICONEXCLAMATION 
		ret
		.endif
		mov	@hFileNew,eax

		mov	esi,offset draw_array
		mov eax,maplen
		mov ecx,eax
		mul ecx
		mov ecx,eax
		.while ecx > 0
			mov edx,dword PTR[esi]
			push ecx
			.if edx == completeWall 
				mov @szBuffer,'C'
			.elseif edx == ironWall 
				mov @szBuffer,'I'
			.elseif edx == homeBird 
				mov @szBuffer,'B'
			.elseif edx == noneWall 
				mov @szBuffer,'A'
			.elseif edx == htank_left 
				mov @szBuffer,'P'
			.elseif edx == htank_left2 
				mov @szBuffer,'Q'
			.else
				mov @szBuffer,'A'
			.endif
			invoke	WriteFile,@hFileNew,addr @szBuffer,1,addr @dwBytesWrite,NULL
			pop ecx
			add esi,4
			dec ecx
		.endw
		invoke	CloseHandle,@hFileNew
		ret
_WriteMap endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _ProcWinMain
; 参数		：		hWnd,uMsg,wParam,lParam
; 功能		：		窗口过程
; 作者		：		黄昱欣，高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc uses ebx edi esi  hWnd,uMsg,wParam,lParam
		LOCAL is_keydown: dword
		mov	eax,uMsg
		.if	eax == WM_CREATE
			invoke	GetClientRect,hWnd,addr stRect
			invoke _Load
			invoke _InitBackground
			invoke _InitMapPix

			invoke CreateWindowEx,0,\
				ADDR bmpBtnCl,ADDR szButtonText,\
				WS_CHILD or WS_VISIBLE,\
				815,580,80,40,hWnd,1,\
				hInstance,NULL
		mov butSave, eax
		.elseif	eax == WM_PAINT
			invoke _PaintMap
			invoke _Print
		.elseif eax == WM_LBUTTONDOWN
			mov eax,lParam
			and eax,0FFFFh
			mov hitpoint.x,eax
			mov eax,lParam
			shr eax,16
			mov hitpoint.y,eax
			invoke _IsRefer,hitpoint.x,hitpoint.y
			.if eax != 0
				mov MouseClick,TRUE
				mov tempthingmask,eax
				add eax,TYPE thing
				mov tempthing,eax
				mov eax,hitpoint.x
				mov esi,tempthing
				sub eax,(thing PTR[esi]).x
				mov subpoint.x,eax
				mov eax,hitpoint.y
				sub eax,(thing PTR[esi]).y
				mov subpoint.y,eax
			.endif
		invoke InvalidateRect,hWnd,NULL,FALSE
		.elseif eax == WM_MOUSEMOVE
			.if MouseClick
				mov eax,lParam
				and eax,0FFFFh
				sub eax,subpoint.x
				mov hitpoint.x,eax
				mov eax,lParam
				shr eax,16
				sub eax,subpoint.y
				mov hitpoint.y,eax
				mov esi,tempthingmask
				invoke _AddList,(thing PTR[esi]).id,hitpoint.x,hitpoint.y,(thing PTR[esi]).w,(thing PTR[esi]).h,(thing PTR[esi]).rop
				mov esi,tempthing
				invoke _AddList,(thing PTR[esi]).id,hitpoint.x,hitpoint.y,(thing PTR[esi]).w,(thing PTR[esi]).h,(thing PTR[esi]).rop
			.endif
		invoke InvalidateRect,hWnd,NULL,FALSE
		.elseif eax == WM_LBUTTONUP
			.if MouseClick
				mov MouseClick,FALSE
				mov eax,lParam
				and eax,0FFFFh
				mov hitpoint.x,eax
				mov eax,lParam
				shr eax,16
				mov hitpoint.y,eax
				mov esi,tempthing
				invoke _CheckWall,hitpoint.x,hitpoint.y,(thing PTR[esi]).id
			.endif
		invoke InvalidateRect,hWnd,NULL,FALSE
		.elseif eax == WM_COMMAND
		   mov eax, wParam
		   .if ax == 1
			invoke _WriteMap
			.if eax ==0
			 ret
			.endif
		   .endif
		  .elseif eax == WM_CLOSE
		   invoke DestroyWindow,hWinMain
		   invoke PostQuitMessage,NULL
		  .else
		   invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		   ret
		  .endif

		xor	eax,eax
		ret
_ProcWinMain	endp



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _WinMain
; 参数		：
; 功能		：		主函数
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain		proc
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		; 注册窗口类
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		invoke  LoadIcon,hInstance,101
		mov @stWndClass.hIcon,eax
		mov @stWndClass.hIconSm,eax 
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
		; 建立并显示窗口
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szCaptionMain,\
			WS_OVERLAPPEDWINDOW,\
			150,100,1055,733,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax

		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	UpdateWindow,hWinMain
		; 消息循环
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
		ret
_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Main:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	_Main