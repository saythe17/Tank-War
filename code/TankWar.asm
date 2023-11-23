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
include		comctl32.inc
include		comdlg32.inc
includelib	comctl32.lib
includelib	comdlg32.lib

include		masm32.inc
include		shell32.inc
includelib	masm32.lib
includelib	shell32.lib
includelib msvcrt.lib
include msvcrt.inc
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data
hInstance		dd	?
hWinMain		dd	?
htank_left		dd	?
htank_left2		dd	?
htank_right		dd	?
htank_right2	dd	?
htank_lmask		dd	?
htank_rmask		dd	?
hrbullet		dd	?
hlbullet		dd	?
hlbulletmask	dd	?
hrbulletmask	dd	?
bg				dd	?
completeWall	dd	?
wallMask		dd	?
brokenWall		dd	?
mainbg			dd	?
welcome			dd	?
hbmp1			dd	?
hbmp2			dd	?
hbmp3			dd	?
hBtn1			dd	?
hBtn2			dd	?
hBtn3			dd	?
hFont			dd	0
bomb1			dd  ?
bomb2			dd  ?
bomb3			dd  ?
bomb1mask		dd  ?
bomb2mask		dd  ?
bomb3mask		dd  ?
blood			dd	?
bloodmask		dd	?
ironWall		dd ?
thing STRUCT
id				dd	?
x				dd	?
y				dd	?
w				dd	?
h				dd	?
rop				dd	?
thing ends
bomb STRUCT
x				dd	?
y				dd	?
flag			dd	?
damage			dd	?
bomb ends
player STRUCT
x				dd	?
y				dd	?
w				dd	?
h				dd	?
speed			dd	?
direc			dd	?
hp				dd	?
mp				dd	?
bomb			dd	?
bomb_inf		bomb	<?,?,?,?>
player ends
bullet STRUCT
x				dd	?
y				dd	?
speed			dd	?
flag			dd	?
direc			dd	?
damage			dd	?
bullet ends
wall	STRUCT
walltype		dd	?
hp				dd	?
wall	ends
wallpix	STRUCT
x				dd	?
y				dd	?
wallpix	ends
pos STRUCT
left			dd  ?
right			dd	?
up				dd	?
down			dd	?
pos ends
bloods STRUCT
x				dd	?
y				dd	?
flag			dd	?
bloods ends
bloodbag		bloods <0,0,0>
bulletpos		pos <0,30,20,30>
tankpos			pos <0,55,10,45>
bullet_array1	bullet 64 dup(<0,0,20,0,0,1>)
bullet_array2	bullet 64 dup(<0,0,20,0,0,1>)
bullet_num1		dd  0
bullet_num2		dd  0
player1			player	<?,?,?,?,?,?,?,?,?,<?,?,?,?>>
player2			player	<?,?,?,?,?,?,?,?,?,<?,?,?,?>>
bomb_interval   dd  31
printlist		thing 128 dup(<?,?,?,?,?,?>)
count			dd	0
stRect			RECT <150,100,1035,690>
wall_array		wall	100	dup(<?,?>)
wallpix_array	wallpix	100 dup(<?,?>)
mywParam		WPARAM 2048 dup(?)
wParamCount		dword 0
timer			dd	  200
blood_interval	dword 200
rseed			dd	?
rand			PROTO C
mp_timer		dd	150
mp_interval		dd	25

szStartButton	db	'Button',0
szSButText		db	'START！',0 
szScene			dd  ?
hpMax			dd	100
mpMax			dd	100
winner			dd	0
text_player1	db	"Player1 HP ",0
text_player2	db	"Player2 HP ",0
text_player1mp	db	"Player1 MP ",0
text_player2mp	db	"Player2 MP ",0
text_playing	db	"The fight is on, defeat your enemy!",0
text_playing2	db	"Get HP++ by eating blood packets.",0
text_win1		db	"The winner is PLAYER 1! Congulations!",0
text_win2		db	"The winner is PLAYER 2! Congulations!",0
text_inst1		db	"For Player 1:",0
text_inst11		db	"                   ↑",0
text_inst12		db	"    Press ← ↓ →  to Move, ",0
text_inst13		db	"    Press Space to Attack. ",0
text_inst14		db	"    Press M to Drop Bomb. ",0
text_inst2		db	"For Player 2:",0
text_inst21		db	"                   W",0
text_inst22		db	"    Press  A  S  D  to Move, ",0
text_inst23		db	"    Press  Q  to Attack. ",0
text_inst24		db	"    Press  F  to Drop Bomb. ",0
msg3 byte "%d",0DH,0AH, 0
msg4 byte "inner:%d",0DH,0AH, 0
szEXE			db	MAX_PATH dup(?)
szEXEsplit		db	'\DrawMap.exe',0
szOpen			db	"open",0
szFileName db '.\map\map1.txt',MAX_PATH dup(?)
szNewFile db MAX_PATH dup(?)

		.const
szClassName		db	'MyClass', 0
szCaptionMain	db	'BIT-TankWar', 0
szText			db	'fightfight', 0
bmpBtnCl		db	"BUTTON"
blnk2			db	0
statClass		db	"STATIC",0

szFilter db 'Text Files(*.txt)',0,'*.txt',0
szsplit         db  '\map\.',0

SY_SCENE_START	equ 0	; 开始场景
SY_SCENE_MAIN	equ 1		; 选择关卡场景
ID_START		equ	31
ID_SELECTMAP	equ 32
ID_DESIGN		equ 33
Static PROTO  :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

walllen			dd	65
maplen			dd	10
szFileExt		db	'文本文件',0,'*.txt',0,0
szErrOpenFile	db	'无法打开源文件',0 
szErrCreateFile db	'无法创建新的文本文件!',0 
szSuccess		db	'文件转换成功，新的文本文件保存为',0dh,0ah,'*s',0 
szSuccessCap	db	 '提示',0 

hpBarWidth		dd	300

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Load
; 参数		：
; 功能		：		加载所用到的bmp图像
; 作者		：		高乃珺，翟子墨，黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Load		proc	uses eax ebx ecx edx esi edi 
	; 坦克
	invoke LoadBitmap, hInstance, 104
	mov htank_left, eax
	invoke LoadBitmap, hInstance, 107
	mov htank_right,eax
	invoke LoadBitmap, hInstance, 105
	mov htank_left2,eax
	invoke LoadBitmap, hInstance, 108
	mov htank_right2,eax
	invoke LoadBitmap, hInstance, 106
	mov htank_lmask,eax
	invoke LoadBitmap, hInstance, 109
	mov htank_rmask,eax
	invoke LoadBitmap, hInstance, 110
	mov bg,eax
	invoke LoadBitmap, hInstance, 111
	mov hlbullet,eax
	invoke LoadBitmap, hInstance, 112
	mov hlbulletmask,eax
	invoke LoadBitmap, hInstance, 113
	mov hrbullet,eax
	invoke LoadBitmap, hInstance, 114
	mov hrbulletmask,eax
	invoke LoadBitmap, hInstance, 115
	mov completeWall,eax
	invoke LoadBitmap, hInstance, 116
	mov wallMask,eax
	invoke LoadBitmap, hInstance, 117
	mov brokenWall,eax	
	invoke LoadBitmap, hInstance, 119
	mov welcome,eax
	invoke LoadBitmap,hInstance,110
	mov mainbg, eax
	invoke LoadBitmap,hInstance,120
	mov hbmp1, eax
	invoke LoadBitmap,hInstance,121
	mov bomb1, eax
	invoke LoadBitmap,hInstance,122
	mov bomb1mask, eax
	invoke LoadBitmap,hInstance,123
	mov bomb2, eax
	invoke LoadBitmap,hInstance,124
	mov bomb2mask, eax
	invoke LoadBitmap,hInstance,125
	mov bomb3, eax
	invoke LoadBitmap,hInstance,126
	mov bomb3mask, eax
	invoke LoadBitmap,hInstance,127
	mov blood, eax
	invoke LoadBitmap,hInstance,128
	mov bloodmask, eax
	invoke LoadBitmap,hInstance,129
	mov hbmp2, eax
	invoke LoadBitmap,hInstance,130
	mov hbmp3, eax
	invoke LoadBitmap, hInstance, 131
	mov ironWall,eax
	ret
_Load endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _AddList
; 参数		：		id:dword,x:dword,y:dword,w:dword,h:dword,rop:dword
; 功能		：		将想要打印的bmp信息添加到printlist中
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_AddList	proc	uses eax ebx ecx edx esi edi id:dword,x:dword,y:dword,w:dword,h:dword,rop:dword
	.if count < 128
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
; 函数名		：		 _Print
; 参数		：		
; 功能		：		将printlist中的全部打印
; 作者		：		黄昱欣，翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Print		proc		uses eax ebx ecx edx esi edi
	local	@stPs:PAINTSTRUCT
	local	hdc:dword 
	local	hdc1:dword
	local	hdc2:dword
	local	mDc:dword
	local	hbitmap:dword
	local	sbrush:dword
	local	@bminfo:BITMAP
	local   @stRect: RECT
	LOCAL	buffer[32]:BYTE
	local	bgRgn:HRGN

	invoke BeginPaint, hWinMain, addr @stPs
	mov hdc,eax
	invoke CreateCompatibleDC,hdc
	mov hdc1,eax
	invoke CreateCompatibleDC,hdc1
	mov hdc2,eax
	invoke CreateCompatibleDC,hdc1	
	mov	mDc,eax
	invoke CreateCompatibleBitmap,hdc,stRect.right,stRect.bottom
	mov hbitmap,eax
	invoke CreateSolidBrush,0ffffffh
	mov sbrush,eax
	invoke SelectObject,hdc1,hbitmap
	invoke SetStretchBltMode,hdc,HALFTONE
	invoke SetStretchBltMode,hdc1,HALFTONE
	invoke SelectObject,mDc,sbrush

	mov esi, 0
	mov edi, offset printlist
	.while esi < count
		invoke GetObject,(thing PTR [edi]).id,type @bminfo,addr @bminfo
		invoke SelectObject,hdc2,(thing PTR [edi]).id
		invoke StretchBlt,hdc1,(thing PTR [edi]).x,(thing PTR [edi]).y,(thing PTR [edi]).w,(thing PTR [edi]).h,hdc2,0,0,@bminfo.bmWidth,@bminfo.bmHeight,(thing PTR [edi]).rop
		inc esi
		add edi, TYPE thing
	.endw
	
	.if szScene == SY_SCENE_MAIN
		;第一个提示框：玩家生命值和MP
		mov		@stRect.left,700
		mov		@stRect.top,35
		mov		@stRect.right,1000
		mov		@stRect.bottom,100
		invoke SetBkMode,hdc1,TRANSPARENT
		invoke SetBkColor,hdc1,00ffffffh
		invoke SetTextColor,hdc1,00ffffffh
		invoke DrawText,hdc1,addr text_player1,-1,addr @stRect,DT_LEFT 
		;生命值框背景
		mov		@stRect.top,55
		mov		@stRect.right,1004
		mov		@stRect.bottom,69
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
        invoke FillRgn,hdc1,bgRgn,sbrush
		;MP框文字
		mov		@stRect.top,75
		mov		@stRect.right,1000
		mov		@stRect.bottom,105
		invoke DrawText,hdc1,addr text_player1mp,-1,addr @stRect,DT_LEFT 
		;MP框背景
		mov		@stRect.top,95
		mov		@stRect.right,1004
		mov		@stRect.bottom,109
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
        invoke FillRgn,hdc1,bgRgn,sbrush

		;计算剩余HP和MP
		mov eax,player1.hp
		mul hpBarWidth
		div hpMax
		add eax,702
		mov		@stRect.left,702
		mov		@stRect.top,57
		mov		@stRect.right,eax
		mov		@stRect.bottom,67
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
		invoke CreateSolidBrush,000000bfh
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
        invoke FillRgn,hdc1,bgRgn,sbrush

		mov eax,player1.mp
		mul hpBarWidth
		div mpMax
		add eax,702
		mov		@stRect.left,702
		mov		@stRect.top,97
		mov		@stRect.right,eax
		mov		@stRect.bottom,107
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
		invoke CreateSolidBrush,00bf0000h
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
        invoke FillRgn,hdc1,bgRgn,sbrush

		;player2
		mov		@stRect.left,700
		mov		@stRect.top,125
		mov		@stRect.right,1004
		mov		@stRect.bottom,155
		invoke CreateSolidBrush,00ffffffh
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
		invoke SetBkMode,hdc1,TRANSPARENT
		invoke SetBkColor,hdc1,00ffffffh
		invoke SetTextColor,hdc1,00ffffffh
		invoke DrawText,hdc1,addr text_player2,-1,addr @stRect,DT_LEFT 

		mov		@stRect.top,145
		mov		@stRect.right,1004
		mov		@stRect.bottom,159
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
        invoke FillRgn,hdc1,bgRgn,sbrush

		mov		@stRect.top,165
		mov		@stRect.right,1004
		mov		@stRect.bottom,185
		invoke DrawText,hdc1,addr text_player2mp,-1,addr @stRect,DT_LEFT 

		mov		@stRect.top,185
		mov		@stRect.right,1004
		mov		@stRect.bottom,199
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
        invoke FillRgn,hdc1,bgRgn,sbrush
		
		;计算剩余HP和MP
		mov eax,player2.hp
		mul hpBarWidth
		div hpMax
		add eax,702
		mov		@stRect.left,702
		mov		@stRect.top,147
		mov		@stRect.right,eax
		mov		@stRect.bottom,157
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
		invoke CreateSolidBrush,000000bfh
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
        invoke FillRgn,hdc1,bgRgn,sbrush

		mov eax,player2.mp
		mul hpBarWidth
		div mpMax
		add eax,702
		mov		@stRect.top,187
		mov		@stRect.right,eax
		mov		@stRect.bottom,197
		invoke CreateRectRgnIndirect,addr @stRect
		mov bgRgn,eax
		invoke CreateSolidBrush,00bf0000h
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
        invoke FillRgn,hdc1,bgRgn,sbrush

		;第二个提示框：游戏状态
		invoke CreateSolidBrush,00ffffffh
		mov sbrush,eax
		invoke SelectObject,mDc,sbrush
		.if winner==0
			mov		@stRect.left,700
			mov		@stRect.top,310
			mov		@stRect.right,1000
			mov		@stRect.bottom,500
			invoke SetBkMode,hdc1,TRANSPARENT
			invoke SetBkColor,hdc1,00ffffffh
			invoke SetTextColor,hdc1,00ffffffh
			invoke DrawText,hdc1,addr text_playing,-1,addr @stRect,DT_CENTER
			mov		@stRect.top,330
			mov		@stRect.bottom,500
			invoke DrawText,hdc1,addr text_playing2,-1,addr @stRect,DT_CENTER
		.else
			mov		@stRect.left,700
			mov		@stRect.top,310
			mov		@stRect.right,1000
			mov		@stRect.bottom,500
			invoke SetBkMode,hdc1,TRANSPARENT
			invoke SetBkColor,hdc1,00ffffffh
			invoke SetTextColor,hdc1,00ffffffh
			.if winner==1
				;invoke wsprintfA,addr buffer,offset szText
				invoke DrawText,hdc1,addr text_win1,-1,addr @stRect,DT_CENTER
			.else	
				invoke DrawText,hdc1,addr text_win2,-1,addr @stRect,DT_CENTER
			.endif
		.endif

		;第三个提示框：游戏说明
		mov		@stRect.left,700
		mov		@stRect.top,435
		mov		@stRect.right,1000
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst1,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,453
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst11,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,470
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst12,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,490
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst13,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,510
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst14,-1,addr @stRect,DT_LEFT

		mov		@stRect.top,540
		mov		@stRect.right,1000
		invoke DrawText,hdc1,addr text_inst2,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,558
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst21,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,575
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst22,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,595
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst23,-1,addr @stRect,DT_LEFT
		mov		@stRect.top,615
		mov		@stRect.bottom,700
		invoke DrawText,hdc1,addr text_inst24,-1,addr @stRect,DT_LEFT


	.endif
	
	invoke StretchBlt,hdc,0,0,stRect.right,stRect.bottom,hdc1,0,0,stRect.right,stRect.bottom,SRCCOPY
	invoke DeleteDC,hbitmap
	invoke DeleteDC,sbrush;;;;
	invoke DeleteDC,mDc
	invoke DeleteDC,hdc2
	invoke DeleteDC,hdc1
	invoke DeleteDC,hdc
	invoke EndPaint,hWinMain,addr @stPs
	mov count,0
	ret
_Print		endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _InitPlayer
; 参数		：		
; 功能		：		初始化两个的坦克参数
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InitPlayer	proc
	inc rseed
	mov player1.w, 55
	mov player1.h, 55
	mov player1.speed, 6
	mov player1.direc, 1
	mov player1.hp, 5
	mov player1.mp, 5
	mov player1.bomb, 1
	mov player1.bomb_inf.flag, 0
	mov player1.bomb_inf.damage, 1
	mov player2.w, 55
	mov player2.h, 55
	mov player2.speed, 6
	mov player2.direc, 0
	mov player2.hp, 5
	mov player2.mp, 5
	mov player2.bomb, 0
	mov player2.bomb_inf.flag, -1
	mov player2.bomb_inf.damage, 1
	mov hpMax,5
	mov mpMax,5
_InitPlayer endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _PaintPlayer
; 参数		：		
; 功能		：		绘制坦克 子弹 炸弹
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_PaintPlayer	proc	uses eax ebx ecx edx esi edi
	;加载背景
	invoke _AddList, mainbg, 0, 0, 1035, 690, SRCPAINT
	;加载血包
	.if bloodbag.flag == 1
		invoke _AddList, blood, bloodbag.x, bloodbag.y, 25, 25, SRCAND
		invoke _AddList, bloodmask, bloodbag.x, bloodbag.y, 25, 25, SRCPAINT
	.endif
	;加载炸弹
	mov eax, player1.bomb_inf.flag
	.if eax > 0 && eax <= 12
		invoke _AddList, bomb1mask, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb1, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCPAINT
	.elseif eax > 12 && eax <= 25
		invoke _AddList, bomb2mask, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb2, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCPAINT
	.elseif eax > 25 && eax <= 30
		invoke _AddList, bomb3mask, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb3, player1.bomb_inf.x, player1.bomb_inf.y, 45, 45, SRCPAINT
	.endif
	mov eax, player2.bomb_inf.flag
	.if eax > 0 && eax <= 12
		invoke _AddList, bomb1mask, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb1, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCPAINT
	.elseif eax > 12 && eax <= 25
		invoke _AddList, bomb2mask, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb2, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCPAINT
	.elseif eax > 25 && eax <= 30
		invoke _AddList, bomb3mask, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCAND
		invoke _AddList, bomb3, player2.bomb_inf.x, player2.bomb_inf.y, 45, 45, SRCPAINT
	.endif
	;加载Player1
	.if player1.hp > 0
		.if player1.direc == 1
			invoke _AddList, htank_rmask, player1.x, player1.y, player1.w, player1.h, SRCAND
			invoke _AddList, htank_right, player1.x, player1.y, player1.w, player1.h, SRCPAINT
		.elseif player1.direc == 0
			invoke _AddList, htank_lmask, player1.x, player1.y, player1.w, player1.h, SRCAND
			invoke _AddList, htank_left, player1.x, player1.y, player1.w, player1.h, SRCPAINT
		.endif
	.endif
	;加载Player2
	.if player2.hp > 0
		.if player2.direc == 0
			invoke _AddList, htank_lmask, player2.x, player2.y, player2.w, player2.h, SRCAND
			invoke _AddList, htank_left2, player2.x, player2.y, player2.w, player2.h, SRCPAINT
		.elseif player2.direc == 1
			invoke _AddList, htank_rmask, player2.x, player2.y, player2.w, player2.h, SRCAND
			invoke _AddList, htank_right2, player2.x, player2.y, player2.w, player2.h, SRCPAINT
		.endif
	.endif

	;加载player1子弹
	mov esi, offset bullet_array1
	xor eax, eax
	.while eax < 64
		mov ecx, (bullet PTR[esi]).flag
		.if ecx == 1
			mov ecx, (bullet PTR[esi]).direc
			.if ecx == 1
				invoke _AddList, hrbulletmask, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCAND
				invoke _AddList, hrbullet, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCPAINT
			.elseif ecx == 0
				invoke _AddList, hlbulletmask, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCAND
				invoke _AddList, hlbullet, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCPAINT
			.endif
		.endif
		add esi, TYPE bullet
		inc eax
	.endw
	;加载player2子弹
	mov esi, offset bullet_array2
	xor eax, eax
	.while eax < 64
		mov ecx, (bullet PTR[esi]).flag
		.if ecx == 1
			mov ecx, (bullet PTR[esi]).direc
			.if ecx == 1
				invoke _AddList, hrbulletmask, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCAND
				invoke _AddList, hrbullet, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCPAINT
			.elseif ecx == 0
				invoke _AddList, hlbulletmask, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCAND
				invoke _AddList, hlbullet, (bullet PTR[esi]).x, (bullet PTR[esi]).y, 30, 30, SRCPAINT
			.endif
		.endif
		add esi, TYPE bullet
		inc eax
	.endw
	ret
_PaintPlayer	endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _GetWall，_IsWall，_HitWall
; 参数		：		xpix,ypix
; 功能		：		判断像素点处是否是墙壁
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetWall proc uses ebx ecx edx esi edi xpix:dword, ypix: dword 
		.if xpix <= 20 || xpix >= 670 || ypix <= 20 || ypix >= 670
			; return 0	
			xor eax,eax
			ret
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
		mov ebx,TYPE wall
		mul ebx

		mov esi,offset wall_array
		add eax,esi

		ret
_GetWall endp

_IsWall proc uses ebx ecx edx esi edi xpix:dword, ypix:dword
		invoke _GetWall,xpix,ypix
		.if eax == 0
			mov eax, 1
			ret
		.endif
		mov esi,eax
		xor eax,eax
		mov edx,(wall PTR[esi]).walltype
		.if edx == 1 
			mov edx,(wall PTR[esi]).hp
			.if edx > 0
				mov eax, 1
			.endif
		.elseif edx == 2
			mov eax,1
		.endif
		ret
_IsWall endp

_HitWall proc uses ebx ecx edx esi edi xpix:dword, ypix:dword
		invoke _GetWall,xpix,ypix
		.if eax == 0
			mov eax,1
			ret
		.endif
 		mov esi,eax
		xor eax,eax
  		mov edx,(wall PTR[esi]).walltype
		.if edx == 1 
			mov edx,(wall PTR[esi]).hp
			.if edx > 0
			dec edx
			mov (wall PTR[esi]).hp,edx
			mov eax,1
			.endif
		.elseif edx == 2
			mov eax,1
		.endif
		ret
_HitWall endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		BmpButton
; 参数		：		wParam:WPARAM
; 功能		：		位图按钮
; 作者		：		翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BmpButton proc hParent:DWORD,a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; BmpButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke BmpButton,hWnd,20,20,100,25,500
    invoke CreateWindowEx,0,\
            ADDR bmpBtnCl,ADDR blnk2,\
            WS_CHILD or WS_VISIBLE or BS_BITMAP,\
            a,b,wd,ht,hParent,ID,\
            hInstance,NULL
    ret

BmpButton endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		SetBmpColor
; 参数		：		wParam:WPARAM
; 功能		：		绘制按钮位图
; 作者		：		翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SetBmpColor proc hBitmap:DWORD

    LOCAL mDC       :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hOldBmp   :DWORD
    LOCAL hReturn   :DWORD
    LOCAL hOldBrush :DWORD

      invoke CreateCompatibleDC,NULL
      mov mDC,eax
      invoke SelectObject,mDC,hBitmap
      mov hOldBmp,eax
      invoke GetSysColor,COLOR_BTNFACE
      invoke CreateSolidBrush,eax
      mov hBrush,eax
      invoke SelectObject,mDC,hBrush
      mov hOldBrush,eax
      invoke GetPixel,mDC,1,1
      invoke ExtFloodFill,mDC,1,1,eax,FLOODFILLSURFACE
      invoke SelectObject,mDC,hOldBrush
      invoke DeleteObject,hBrush
      invoke SelectObject,mDC,hBitmap
      mov hReturn,eax
      invoke DeleteDC,mDC
      mov eax,hReturn
    ret

SetBmpColor endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Move
; 参数		：		wParam
; 功能		：		针对按键做出相应调整
; 作者		：		黄昱欣，翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Move proc uses eax ebx ecx edx esi edi wParam:WPARAM
	.if wParam == VK_LEFT && player1.hp > 0
		mov eax, player1.x
		sub eax, player1.speed
		mov ebx, player1.y
		add ebx, tankpos.up
		; 判断tank左上角是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp1

		mov eax, player1.x
		sub eax, player1.speed
		mov ebx, player1.y
		add ebx, tankpos.down
		; 判断tank左下角是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp1

		mov eax, player1.x
		sub eax, player1.speed
		mov player1.x, eax
		jmp1:
		mov player1.direc, 0
	.elseif wParam == VK_RIGHT && player1.hp > 0
		mov eax, player1.x
		add eax, player1.speed
		add eax, player1.w
		mov ebx, player1.y
		; 判断是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp2

		mov eax, player1.x
		add eax, player1.speed
		add eax, player1.w
		mov ebx, player1.y
		add ebx, tankpos.down
		; 判断是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp2

		mov eax, player1.x
		add eax, player1.speed
		mov player1.x, eax
		jmp2:
		mov player1.direc,1
	.elseif wParam == VK_DOWN && player1.hp > 0
		mov eax, player1.y
		add eax, tankpos.down
		add eax, player1.speed
		mov ebx, player1.x
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp3

		mov eax, player1.y
		add eax, tankpos.down
		add eax, player1.speed
		mov ebx, player1.x
		add ebx, player1.w
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp3

		mov eax, player1.y
		add eax, player1.speed
		mov player1.y, eax
		jmp3:
	.elseif wParam == VK_UP && player1.hp > 0
		mov eax, player1.y
		add eax, tankpos.up
		sub eax, player1.speed
		mov ebx, player1.x
		;判断是否为墙壁
		invoke _IsWall, ebx, eax
		cmp eax, 1
		je jmp4

		mov eax, player1.y
		add eax, tankpos.up
		sub eax, player1.speed
		mov ebx, player1.x
		add ebx, player1.w
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp4

		mov eax, player1.y
		sub eax, player1.speed
		mov player1.y, eax
		jmp4:
	.elseif wParam == VK_SPACE && player1.hp > 0 && player1.mp > 0
		.if bullet_num1 == 64
			mov bullet_num1, 0
		.endif
		mov eax, bullet_num1
		mov ebx, TYPE bullet
		mul ebx
		mov esi, offset bullet_array1
		add esi, eax
		mov eax, player1.y
		add eax, 10
		mov (bullet PTR[esi]).y, eax
		mov eax, player1.direc
		mov (bullet PTR[esi]).direc, eax
		.if eax == 1
			mov eax, player1.x
			add eax, 45
			mov (bullet PTR[esi]).x, eax
		.elseif eax == 0
			mov eax, player1.x
			sub eax, 20
			mov (bullet PTR[esi]).x, eax
		.endif
		mov (bullet PTR[esi]).flag, 1
		inc bullet_num1
		dec player1.mp
	.elseif wParam == VK_M && player1.hp > 0
		.if player1.bomb == 0 && player1.bomb_inf.flag == 0
			mov eax, player1.x
			add eax, 5
			mov player1.bomb_inf.x, eax
			mov eax, player1.y
			add eax, 5
			mov player1.bomb_inf.y, eax
			mov player1.bomb_inf.flag, 1
			mov eax, bomb_interval
			mov player1.bomb, eax
		.endif
	; Player2
	.elseif wParam == VK_A && player2.hp > 0
		mov eax, player2.x
		sub eax, player2.speed
		mov ebx, player2.y
		add ebx, tankpos.up
		; 判断tank左上角是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp5

		mov eax, player2.x
		sub eax, player2.speed
		mov ebx, player2.y
		add ebx, tankpos.down
		; 判断tank左下角是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp5

		mov eax, player2.x
		sub eax, player2.speed
		mov player2.x, eax
		jmp5:
		mov player2.direc, 0
	.elseif wParam == VK_D  && player2.hp > 0
		mov eax, player2.x
		add eax, player2.w
		add eax, player2.speed
		mov ebx, player2.y
		; 判断是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp6

		mov eax, player2.x
		add eax, player2.w
		add eax, player2.speed
		mov ebx, player2.y
		add ebx, tankpos.down
		; 判断是否为墙壁
		invoke _IsWall, eax, ebx
		cmp eax, 1
		je jmp6

		mov eax, player2.x
		add eax, player2.speed
		mov player2.x, eax
		jmp6:
		mov player2.direc,1
	.elseif wParam == VK_S && player2.hp > 0
		mov eax, player2.y
		add eax, tankpos.down
		add eax, player2.speed
		mov ebx, player2.x
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp7

		mov eax, player2.y
		add eax, tankpos.down
		add eax, player2.speed
		mov ebx, player2.x
		add ebx, player2.w
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp7

		mov eax, player2.y
		add eax, player2.speed
		mov player2.y, eax
		jmp7:
	.elseif wParam == VK_W && player2.hp > 0
		mov eax, player2.y
		add eax, tankpos.up
		sub eax, player2.speed
		mov ebx, player2.x
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp8

		mov eax, player2.y
		add eax, tankpos.up
		sub eax, player2.speed
		mov ebx, player2.x
		add ebx, player2.w
		;判断是否为墙壁
		invoke _IsWall,ebx,eax
		cmp eax, 1
		je jmp8

		mov eax, player2.y
		sub eax, player2.speed
		mov player2.y, eax
		jmp8:
	.elseif wParam == VK_Q && player2.hp > 0  && player2.mp > 0
		.if bullet_num2 == 64
			mov bullet_num2, 0
		.endif
		mov eax, bullet_num2
		mov ebx, TYPE bullet
		mul ebx
		mov esi, offset bullet_array2
		add esi, eax
		mov eax, player2.y
		add eax, 10
		mov (bullet PTR[esi]).y, eax
		mov eax, player2.direc
		mov (bullet PTR[esi]).direc, eax
		.if eax == 1
			mov eax, player2.x
			add eax, 45
			mov (bullet PTR[esi]).x, eax
		.elseif eax == 0
			mov eax, player2.x
			sub eax, 20
			mov (bullet PTR[esi]).x, eax
		.endif
		mov (bullet PTR[esi]).flag, 1
		inc bullet_num2
		dec player2.mp ;;;;;;;;;;;
	.elseif wParam == VK_F && player2.hp > 0
		.if player2.bomb == 0 && player2.bomb_inf.flag == 0
			mov eax, player2.x
			add eax, 5
			mov player2.bomb_inf.x, eax
			mov eax, player2.y
			add eax, 5
			mov player2.bomb_inf.y, eax
			mov player2.bomb_inf.flag, 1
			mov eax, bomb_interval
			mov player2.bomb, eax
		.endif
	.endif
	ret
_Move endp


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Bullettank
; 参数		：		wParam
; 功能		：		检测子弹和炸弹和人、血包是否碰撞
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Bullettank proc uses eax ebx ecx edx esi edi
		local bulletx,bullety
	.if player1.hp <= 0 || player2.hp <= 0
		ret
	.endif
	;检测player1子弹和player2的碰撞
	mov esi, offset bullet_array1
	xor ecx, ecx
	.while ecx < 64
		mov ebx, (bullet PTR[esi]).flag
		.if ebx == 1
			xor eax, eax
			mov eax, 19
			add eax, (bullet PTR[esi]).y
			mov bullety,eax
			xor eax, eax
			mov eax, (bullet PTR[esi]).x
			mov bulletx,eax

			
			.if bulletx < 20 || bulletx > 650
				mov (bullet PTR [esi]).flag, 0
				jmp jp1
			.endif
			invoke _HitWall,bulletx,bullety
			test eax,eax
			.if eax != 0
				mov (bullet PTR [esi]).flag, 0
				jmp jp1
			.endif


			xor edi, edi
			xor edx, edx
			mov edi, player2.y
			add edi, tankpos.up
			mov eax,bullety
			cmp eax, edi
			jl jp1
			mov edi, player2.y
			add edi, tankpos.down
			cmp eax, edi
			jg jp1

			
			mov eax,bulletx
			xor edi, edi
			xor edx, edx
			mov edi, player2.x
			mov edx, (bullet PTR[esi]).direc
			.if edx == 0
				add eax, bulletpos.left
				add edi, tankpos.right
				cmp eax, edi
				jg jp1
				sub edi, 20
				cmp eax, edi
				jl jp1
				mov (bullet PTR [esi]).flag, 0
				dec player2.hp
			.else
				add eax, bulletpos.right
				add edi, tankpos.left
				cmp eax, edi
				jl jp1
				add edi, 100
				cmp eax, edi
				jg jp1
				mov (bullet PTR [esi]).flag, 0
				dec player2.hp
			.endif
			jp1:
		.endif
		inc ecx
		add esi, TYPE bullet
	.endw
	;检测player1炸弹和player2的碰撞
	.if player1.bomb_inf.flag > 25
		mov eax, player2.x
		add eax, 45
		mov ebx, player1.bomb_inf.x
		cmp eax, ebx
		jle jpp1
		sub eax, 80
		cmp eax, ebx
		jge jpp1
		mov eax, player2.y
		add eax, 45
		mov ebx, player1.bomb_inf.y
		cmp eax, ebx
		jle jpp1
		sub eax, 80
		cmp eax, ebx
		jge jpp1
		
		dec player2.hp
		mov player1.bomb_inf.flag, 0
		jpp1:
	.endif
	;检测player2和血包的碰撞
	.if bloodbag.flag == 1
		mov eax, bloodbag.x
		add eax, 25
		mov ebx, player2.x
		cmp eax, ebx
		jle jpp3
		sub eax, 80
		cmp eax, ebx
		jge jpp3
		mov eax, bloodbag.y
		add eax, 15
		mov ebx, player2.y
		cmp eax, ebx
		jle jpp3
		sub eax, 60
		cmp eax, ebx
		jge jpp3
		
		.if player2.hp < 5
			inc player2.hp
		.endif
		mov bloodbag.flag, 0
		jpp3:
	.endif

	;检查player1是否获胜
	.if player2.hp==0
		mov winner,1
		ret
	.endif

	;检测player2子弹和player1的碰撞
	mov esi, offset bullet_array2
	xor ecx, ecx
	.while ecx < 64
		mov ebx, (bullet PTR[esi]).flag
		.if ebx == 1
			xor eax, eax
			mov eax, 19
			add eax, (bullet PTR[esi]).y
			mov bullety,eax
			xor eax, eax
			mov eax, (bullet PTR[esi]).x
			mov bulletx,eax

			.if bulletx < 20 || bulletx > 650
				mov (bullet PTR [esi]).flag, 0
				jmp jp1
			.endif
			invoke _HitWall,bulletx,bullety
			test eax,eax
			.if eax!=0
				mov (bullet PTR [esi]).flag, 0
				jmp jp2
			.endif

			xor eax, eax
			xor edi, edi
			xor edx, edx
			mov eax, bullety
			mov edi, player1.y
			add edi, tankpos.up
			cmp eax, edi
			jl jp2
			mov edi, player1.y
			add edi, tankpos.down
			cmp eax, edi
			jg jp2
			xor eax, eax
			xor edi, edi
			xor edx, edx
			mov edi, player1.x
			mov eax, bulletx
			mov edx, (bullet PTR[esi]).direc
			.if edx == 0
				add eax, bulletpos.left
				add edi, tankpos.right
				cmp eax, edi
				jg jp2
				sub edi, 20
				cmp eax, edi
				jl jp2
				mov (bullet PTR [esi]).flag, 0
				dec player1.hp
			.else
				add eax, bulletpos.right
				add edi, tankpos.left
				cmp eax, edi
				jl jp2
				add edi, 100
				cmp eax, edi
				jg jp2
				mov (bullet PTR [esi]).flag, 0
				dec player1.hp
			.endif
			jp2:
		.endif
		inc ecx
		add esi, TYPE bullet
	.endw
	;检测player2炸弹和player1的碰撞
	.if player2.bomb_inf.flag > 25
		mov eax, player1.x
		add eax, 45
		mov ebx, player2.bomb_inf.x
		cmp eax, ebx
		jle jpp2
		sub eax, 80
		cmp eax, ebx
		jge jpp2
		mov eax, player1.y
		add eax, 45
		mov ebx, player2.bomb_inf.y
		cmp eax, ebx
		jle jpp2
		sub eax, 80
		cmp eax, ebx
		jge jpp2
		
		dec player1.hp
		mov player2.bomb_inf.flag, 0
		jpp2:
	.endif
	;检测player1和血包的碰撞
	.if bloodbag.flag == 1
		mov eax, bloodbag.x
		add eax, 25
		mov ebx, player1.x
		cmp eax, ebx
		jle jpp4
		sub eax, 80
		cmp eax, ebx
		jge jpp4
		mov eax, bloodbag.y
		add eax, 15
		mov ebx, player1.y
		cmp eax, ebx
		jle jpp4
		sub eax, 60
		cmp eax, ebx
		jge jpp4
		
		.if player1.hp < 5
			inc player1.hp
		.endif
		mov bloodbag.flag, 0
		jpp4:
	.endif
	;检查player2是否获胜
	.if player2.hp==0
		mov winner,2
	.endif
	ret
_Bullettank endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名  ：   _OpenMap
; 参数  ：  
; 功能  ：  更换地图文件
; 作者  ：  高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenMap proc uses eax ebx ecx edx esi edi
   local @stOF:OPENFILENAME
   invoke  GetCurrentDirectory,MAX_PATH,addr szNewFile
   mov  edi,offset szNewFile
   mov  edx,offset szsplit
   invoke lstrcat,edi,edx  
   invoke RtlZeroMemory,addr @stOF,sizeof @stOF
   mov @stOF.lStructSize,sizeof @stOF
   push hWinMain
   pop @stOF.hwndOwner
   mov @stOF.lpstrFilter,offset szFilter
   mov @stOF.lpstrFile,offset szNewFile
   mov @stOF.nMaxFile,MAX_PATH
   mov @stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
   invoke GetOpenFileName,addr @stOF
   .if eax
    mov  edi,offset szFileName
    mov     edx,offset szNewFile
    invoke lstrcpy,edi,edx
   .endif
   ret
_OpenMap endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _PaintMap
; 参数		：		
; 功能		：		初始绘画地图
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

_PaintMap	proc	uses eax ebx ecx edx esi edi
			mov	esi,offset wall_array
			mov	edi,offset wallpix_array
			mov eax,maplen
			mov ecx,eax
			mul ecx
			mov ecx,eax
			.while ecx > 0
			mov edx,(wall PTR[esi]).walltype
			.if  edx == 1 
				mov edx,(wall PTR[esi]).hp
				.if edx == 2
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, completeWall, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
				.elseif edx == 1
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, brokenWall, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
				.endif
			.elseif edx == 2
				invoke _AddList, wallMask, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCAND
				invoke _AddList, ironWall, (wallpix PTR[edi]).x, (wallpix PTR[edi]).y, walllen, walllen, SRCPAINT
			.endif
			add esi,TYPE wall
			add edi,TYPE wallpix
			dec ecx
			.endw
			ret
_PaintMap	endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Random
; 参数		：		
; 功能		：		生成0-max之间的随机数
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Random proc uses ebx ecx edx esi edi max:dword
	invoke rand
	xor edx,edx
	mov ebx,max
	div ebx
	mov eax,edx
	ret
_Random endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _Blood
; 参数		：		
; 功能		：		随机产生血包
; 作者		：		黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Blood proc uses eax ebx ecx edx esi edi
	local @x:dword
	local @y:dword
	.while 1
		invoke _Random, 690
		mov @x, eax
		invoke _Random, 690
		mov @y, eax
		invoke _IsWall, @x, @y
		.if eax == 0
			mov eax, @x
			sub eax, 20
			.while eax > 65
				sub eax, 65
			.endw
			mov ebx, eax
			mov eax, @x
			add eax, 20
			sub eax, ebx
			mov @x, eax

			mov eax, @y
			sub eax, 20
			.while eax > 65
				sub eax, 65
			.endw
			mov ebx, eax
			mov eax, @y
			add eax, 20
			sub eax, ebx
			mov @y, eax
			.break
		.endif
	.endw
	mov eax, @x
	mov bloodbag.x, eax
	mov eax, @y
	mov bloodbag.y, eax
	mov bloodbag.flag, 1
	ret
_Blood endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _InitMap
; 参数		：		
; 功能		：		根据地图文件初始化地图
; 作者		：		高乃珺
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InitMap proc uses eax ebx ecx edx esi edi
		local @hFile,@hFileNew,@dwBytesRead
		local @szNewFile[MAX_PATH]:byte
		local @szReadBuffer[512]:byte

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

		;打开地图文件，得到句柄@hFile
		invoke CreateFile,addr szFileName,GENERIC_READ,\
				FILE_SHARE_READ,0,\
				OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if		eax == INVALID_HANDLE_VALUE
			invoke GetLastError
			invoke MessageBox,hWinMain,addr szErrOpenFile,\
					NULL,MB_OK or MB_ICONEXCLAMATION
			ret
		.endif
		mov		@hFile,eax

		;读取文件，初始化地图列表
		xor	eax,eax
		mov	@dwBytesRead,eax
		xor edi,edi
		xor ebx,ebx
		mov edi,offset wall_array
		mov ebx,offset wallpix_array
		.while TRUE
			lea	esi,@szReadBuffer
			invoke ReadFile,@hFile,esi,sizeof @szReadBuffer,\
			addr @dwBytesRead,0
			.break .if ! @dwBytesRead
			xor ecx,ecx
			mov ecx,@dwBytesRead
_PaintMapLoop:
			.if byte PTR [esi]=='A'
				mov (wall PTR[edi]).walltype,0
				mov (wall PTR[edi]).hp,0
			   .elseif byte PTR [esi]=='C'
				mov (wall PTR[edi]).walltype,1
				mov (wall PTR[edi]).hp,2
			   .elseif byte PTR [esi]=='I'
				mov (wall PTR[edi]).walltype,2
			   .elseif byte PTR [esi]=='P'
				mov eax,(wallpix PTR[ebx]).x
				mov player1.x,eax
				mov eax,(wallpix PTR[ebx]).y
				mov player1.y,eax
			   .elseif byte PTR [esi]=='Q'
				mov eax,(wallpix PTR[ebx]).x
				mov player2.x,eax
				mov eax,(wallpix PTR[ebx]).y
				mov player2.y,eax
			   .else
				jmp _PaintEnd
			.endif
			add edi,TYPE wall
			add ebx,TYPE wallpix
_PaintEnd:
			inc esi
			loop _PaintMapLoop
		.endw

		invoke	CloseHandle,@hFile
		ret
_InitMap	endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _DrawMap
; 参数		：		wParam:HDC
; 功能		：		绘制背景
; 作者		：		翟子墨
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DrawMap proc hWin:HWND
		local   @stPs: PAINTSTRUCT
        local   @stRect: RECT
        local   mDC
		local	hDC
		LOCAL	buffer[32]:BYTE
		
	.if szScene == SY_SCENE_START
		invoke _AddList, welcome, 0, 0, 1136, 640, SRCPAINT
		invoke _Print

	.elseif szScene == SY_SCENE_MAIN
		invoke _PaintPlayer
		invoke _PaintMap
		invoke _Print

	.endif
	ret
_DrawMap endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _ProcWinMain
; 参数		：		hWnd,uMsg,wParam,lParam
; 功能		：		窗口过程
; 作者		：		高乃珺，翟子墨，黄昱欣
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc uses ebx edi esi  hWnd,uMsg,wParam,lParam
		LOCAL is_keydown: dword
		mov is_keydown, 0
		mov	eax,uMsg
		.if	eax == WM_CREATE
			invoke GetClientRect,hWnd,addr stRect
			invoke _Load
			invoke SetTimer,hWnd,1,100,NULL
			invoke SetBmpColor,hbmp1
			mov hbmp1,eax
			invoke BmpButton,hWnd,250,410,150,54,ID_START
			mov hBtn1, eax
			invoke SendMessage,hBtn1,BM_SETIMAGE,0,hbmp1

			invoke SetBmpColor,hbmp2
			mov hbmp2,eax
			invoke BmpButton,hWnd,250,470,150,54,ID_SELECTMAP
			mov hBtn2, eax
			invoke SendMessage,hBtn2,BM_SETIMAGE,0,hbmp2

			invoke SetBmpColor,hbmp3
			mov hbmp3,eax
			invoke BmpButton,hWnd,250,530,150,54,ID_DESIGN
			mov hBtn3, eax
			invoke SendMessage,hBtn3,BM_SETIMAGE,0,hbmp3

			mov szScene, SY_SCENE_START

		.elseif	eax == WM_PAINT
			invoke _DrawMap,hWnd	
		.elseif eax == WM_KEYUP && winner == 0 ;当决出获胜者后不再移动
			.if wParamCount > 0
				push edi
				push esi
				push ecx
				push eax
				mov ecx, 0
				mov edi, offset mywParam
				.while ecx < wParamCount
					mov eax, wParam
					.if (WPARAM PTR [edi]) == eax
						.while ecx < wParamCount
							mov esi, edi
							add esi, TYPE WPARAM
							mov eax, (WPARAM PTR [esi])
							mov (WPARAM PTR [edi]), eax
							add edi, TYPE WPARAM
							add ecx, 1
						.endw
						sub wParamCount, 1
						.break
					.endif
					add edi, TYPE WPARAM
					add ecx, 1
				.endw
				pop eax
				pop ecx
				pop esi
				pop edi
			.endif
		.elseif eax == WM_KEYDOWN && winner == 0	;当决出获胜者后不再移动
			.if wParam == VK_SPACE || wParam == VK_Q
				invoke _Move, wParam
				ret
			.endif

			; 检测当前键是否已经被按下了
			mov ecx, 0
			mov edi, offset mywParam
			mov ebx, TYPE WPARAM
			.while ecx < wParamCount
				mov eax, wParam
				.if (WPARAM PTR [edi]) == eax
					mov is_keydown, 1
					.break
				.endif
				add ecx, 1
				add edi, ebx
			.endw

			mov eax, is_keydown
			.if eax == 1
				ret
			.endif

			; 加入mywParam
			mov edi, offset mywParam
			mov eax, wParamCount
			mov ebx, TYPE WPARAM
			mul ebx
			add edi, eax
			mov eax, wParam
			mov (WPARAM PTR [edi]), eax
			add wParamCount, 1
			
			invoke _Move, wParam

		.elseif eax == WM_TIMER
			; 随机产生血包
			dec timer
			.if timer == 1
				invoke _Blood
				mov eax, blood_interval
				mov timer, eax
			.endif

			dec mp_timer
			.if mp_timer == 1
				mov eax,mpMax
				.if player1.mp < eax
					inc player1.mp
				.endif
				.if player2.mp < eax
					inc player2.mp
				.endif
				mov eax, mp_interval
				mov mp_timer, eax
			.endif

			; 更新炸弹信息
			.if player1.bomb > 0
				dec player1.bomb
			.endif
			.if player1.bomb_inf.flag > 0
				.if player1.bomb_inf.flag == 30
					mov player1.bomb_inf.flag, -1
				.else
					inc player1.bomb_inf.flag
				.endif
			.endif
			.if player2.bomb > 0
				dec player2.bomb
			.endif
			.if player2.bomb_inf.flag > 0
				.if player2.bomb_inf.flag == 30
					mov player2.bomb_inf.flag, -1
				.else
					inc player2.bomb_inf.flag
				.endif
			.endif
			; 遍历wParam，移动玩家
			push edi
			mov ecx, 0
			mov edi, offset mywParam
			.while ecx < wParamCount
				mov eax, (WPARAM PTR [edi])
				invoke _Move, eax
				add edi, TYPE WPARAM
				add ecx, 1
			.endw
			pop edi

			;更新player1子弹位置
			mov esi, offset bullet_array1
			xor ecx, ecx
			.while ecx < 64
				mov ebx, (bullet PTR[esi]).flag
				.if ebx == 1
					mov edx, (bullet PTR[esi]).direc
					mov eax, (bullet PTR[esi]).x
					.if edx == 1
						.if eax >= 1100
						mov ebx, 0
						.else
						mov eax, (bullet PTR[esi]).speed
						add (bullet PTR[esi]).x, eax
						.endif
					.else
						.if eax <= 0
							mov ebx, 0
						.else
							mov eax, (bullet PTR[esi]).speed
							sub (bullet PTR[esi]).x, eax
						.endif
					.endif
					mov (bullet PTR[esi]).flag, ebx
				.endif
				inc ecx
				add esi, TYPE bullet
			.endw
			;更新player2子弹位置
			mov esi, offset bullet_array2
			xor ecx, ecx
			.while ecx < 64
				mov ebx, (bullet PTR[esi]).flag
				.if ebx == 1
					mov edx, (bullet PTR[esi]).direc
					mov eax, (bullet PTR[esi]).x
					.if edx == 1
						.if eax >= 1100
						mov ebx, 0
						.else
						mov eax, (bullet PTR[esi]).speed
						add (bullet PTR[esi]).x, eax
						.endif
					.else
						.if eax <= 0
							mov ebx, 0
						.else
							mov eax, (bullet PTR[esi]).speed
							sub (bullet PTR[esi]).x, eax
						.endif
					.endif
					mov (bullet PTR[esi]).flag, ebx
				.endif
				inc ecx
				add esi, TYPE bullet
			.endw
			invoke _Bullettank
			invoke InvalidateRect,hWnd,NULL,FALSE
		.elseif eax == WM_COMMAND
			mov eax, wParam
			.if ax == ID_START
				invoke DeleteObject, welcome
				invoke ShowWindow, hBtn1, SW_HIDE
				invoke ShowWindow, hBtn2, SW_HIDE
				invoke ShowWindow, hBtn3, SW_HIDE
				mov szScene, SY_SCENE_MAIN
				invoke _InitPlayer
				invoke _InitMap

			.elseif ax == ID_SELECTMAP
				invoke ShowWindow, hBtn1, SW_HIDE
				invoke ShowWindow, hBtn2, SW_HIDE
				invoke ShowWindow, hBtn3, SW_HIDE
				;选择地图
				invoke _OpenMap
				invoke DeleteObject, welcome
				mov szScene, SY_SCENE_MAIN
				invoke _InitPlayer
				invoke _InitMap

			.elseif ax == ID_DESIGN
				;自定义地图
				invoke  GetCurrentDirectory,MAX_PATH,addr szEXE
				mov  edi,offset szEXE
				mov  edx,offset szEXEsplit
				invoke lstrcat,edi,edx  
				invoke ShellExecute,NULL,offset szOpen,offset szEXE,NULL,NULL,SW_SHOWNORMAL
			.endif
		.elseif	eax == WM_CLOSE
			invoke	DestroyWindow,hWinMain
			invoke	PostQuitMessage,NULL
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif

		xor	eax,eax
		ret
_ProcWinMain	endp



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 函数名		：		 _WinMain
; 参数		：
; 功能		：		主函数
; 作者		：
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