�����<H�<H  &�<H�<H�<H�<H�<H�<H
	section	BiTS,code

OPENLIBRARY:	EQU	-408
CLOSELIBRARY:	EQU	-414
OPEN:		EQU	-30
CLOSE:		EQU	-36
LOCK:		EQU	-84
UNLOCK:		EQU	-90
EXAMINE:	EQU	-102
EXNEXT:		EQU	-108

MAXFILES:	EQU	250	;change
MAXTYPES:	EQU	15	;change
NYMENY:		EQU	0
ANT_BAN_MENY:	equ	18	;antal banor/menysida


j:
	move.l	d0,return
	lea	files,a0
	lea	menyer,a1
	lea	text,a2

	move.l	a0,filerna
	move.l	a1,menyerna
	move.l	a2,texterna

	move.b	#'1',ch_1
	move.b	#'2',ch_2
	move.b	#'3',ch_3
	move.b	#'4',ch_4
	move.b	#'5',ch_5
	move.b	#'6',ch_6

	MOVE.L	$4.W,A6
	LEA.L	DOSNAME(PC),A1
	JSR	OPENLIBRARY(A6)		; �ppna dos.library
	MOVE.L	D0,DOSBASE
	BEQ.L	NEXIT
	MOVE.L	D0,A6

	MOVE.L	#DIRNAME,D1
	MOVEQ	#-2,D2			; L�smod
	JSR	LOCK(A6)		; H�mta nyckel
	MOVE.L	D0,DIRLOCK		; Spar nyckel

	MOVE.L	D0,D1
	MOVE.L	#INFO+2,D2
	JSR	EXAMINE(A6)		; H�mta dirinfo
	TST.L	D0
	BEQ.W	DIRNEXIT

	move.l	filerna,a5
	lea	space,a4
GETDIR:	
	MOVE.L	DIRLOCK(PC),D1
	MOVE.L	#INFO+2,D2
	JSR	EXNEXT(A6)		; N�sta objekt
	TST.L	D0			; Sista objektet?
	BEQ.S	DIRNEXIT

	move.l	a5,(a4)+
	MOVE.L	#INFO+10,D1
	AND.W	#$FFFC,D1		; Fixa j�mn address
	MOVE.L	D1,A0
	moveq	#1,d7
MOVENAME3:
	MOVE.B	(A0)+,(A5)+
	DBF	D7,MOVENAME3

	moveq	#0,d5
	MOVEQ	#4,D7
MOVENAME:
	MOVE.B	(A0),(A5)+		; Flytta namnet
	moveq	#0,d6
	move.b	(a0)+,d6
	cmp.b	#'a',d6
	bmi.s	.n
	bclr	#5,d6
.n:	sub.b	#32,d6
	and.b	#%00111111,d6
	lsl.l	#6,d5
	or.b	d6,d5
	DBF	D7,MOVENAME
	move.b	d5,3(a4)
	lsr.l	#8,d5
	move.b	d5,2(a4)
	lsr.l	#8,d5
	move.b	d5,1(a4)
	lsr.l	#8,d5
	move.b	d5,0(a4)
	
	addq.l	#4,a4

	MOVEQ	#27,D7
MOVENAME2:
	MOVE.B	(A0)+,(A5)+
	DBF	D7,MOVENAME2

	move.b	#0,(a5)+

	addq.l	#1,NOFILES
	BRA.S	GETDIR

DIRNEXIT:
	move.l	#0,(a4)+
	move.b	#0,(a5)+
	MOVE.L	DIRLOCK(PC),D1
	JSR	UNLOCK(A6)		; Dir f�rdig


NEXIT:	move.l	NOFILES,d7
sortloop:			;sortera banorna
	lea	space,a1
	move.l	nofiles,d6
	subq.l	#1,d6
.sort:	move.l	12(a1),d0
	beq.s	.ok
	cmp.l	4(a1),d0
	bpl.s	.ok
	move.l	(a1),d0
	move.l	4(a1),d1
	move.l	8(a1),(a1)
	move.l	12(a1),4(a1)
	move.l	d0,8(a1)
	move.l	d1,12(a1)
.ok:	addq.l	#8,a1
	dbf	d6,.sort
	dbf	d7,sortloop
	
;---- dir types:

	MOVE.L	#TYPESNAME,D1
	MOVEQ	#-2,D2			; L�smod
	JSR	LOCK(A6)		; H�mta nyckel
	MOVE.L	D0,DIRLOCK		; Spar nyckel

	MOVE.L	D0,D1
	MOVE.L	#INFO+2,D2
	JSR	EXAMINE(A6)		; H�mta dirinfo
	TST.L	D0
	BEQ.S	.DIRNEXIT

	lea	types_dir,a5
.GETDIR:	
	MOVE.L	DIRLOCK(PC),D1
	MOVE.L	#INFO+2,D2
	JSR	EXNEXT(A6)		; N�sta objekt
	TST.L	D0			; Sista objektet?
	BEQ.S	.DIRNEXIT

	MOVE.L	#INFO+10,D1
	AND.W	#$FFFC,D1		; Fixa j�mn address
	MOVE.L	D1,A0
	moveq	#1,d7
.MOVENAME:
	MOVE.B	(A0)+,(A5)
	bclr	#5,(a5)+
	DBF	D7,.MOVENAME

	BRA.S	.GETDIR

.DIRNEXIT:
	MOVE.L	DIRLOCK(PC),D1
	JSR	UNLOCK(A6)		; Dir f�rdig

	move.w	#0,(a5)+

	lea	types_dir,a0
antlop:
	tst.w	(a0)+
	bne.s	antlop
	move.l	a0,d7
	sub.l	#types_dir,d7
	asr.l	#1,d7
.sortb:	lea	types_dir,a0
.sort:	tst.w	2(a0)
	beq.s	.ut
	move.w	2(a0),d0
	cmp.w	(a0),d0
	bpl.s	.next
	move.w	(a0),d0
	move.w	2(a0),(a0)
	move.w	d0,2(a0)
.next:	addq.l	#2,a0
	bra.s	.sort
.ut:	dbf	d7,.sortb

	lea	types_dir,a4
	lea	typesfiler,a5
laddloop:
	move.w	(a4)+,filtemp+10
	lea	filtemp,a0
	move.l	a5,d0
	bsr	loadfile
	add.l	#400,a5
	tst.w	(a4)
	bne.s	laddloop

	lea	uleadrs,a1
	move.l	menyerna,a2
	lea	text,a4
	lea	typesfiler,a6
	moveq	#58,d0
	moveq	#0,d1
	lea	inittext,a0
	move.l	#0,4(a2)
	move.l	a4,(a2)
.qwloop:move.b	(a0)+,(a4)+
	bne.s	.qwloop
	sub.l	#1,a4
.qweloop:
	move.l	d1,d2
	move.l	d1,d7
	mulu	#20,d1
	move.l	#65,8(a2,d1.l)
	move.l	d0,12(a2,d1.l)
	move.l	#nymeny,16(a2,d1.l)
	move.l	a2,(a1)
	add.l	#20,d1
	add.l	d1,(a1)+
	move.l	d2,d1
	add.l	#1,d1
	add.l	#1,4(a2)
	move.b	#'�',(a4)+
	move.b	#'b',(a4)+
	move.b	#65,(a4)+
	move.b	d0,(a4)+
	add.l	#9,d0
	move.l	a6,d2
	add.l	#40,a6
.menoloop:
	move.b	(a6)+,(a4)+
	bne.s	.menoloop
	sub.l	#1,a4
	move.l	d2,a6
	add.l	#400,a6
	move.l	d7,d1
	add.l	#1,d1
	tst.w	(a6)
	bne.s	.qweloop

	mulu	#20,d1
	move.l	#15,8(a2,d1.l)
	move.l	#225,12(a2,d1.l)
	move.l	#nymeny,16(a2,d1.l)
	move.l	return,d0
	move.l	d0,20(a2,d1.l)
	move.l	#0,24(a2,d1.l)
	move.b	#'�',(a4)+
	move.b	#'f',(a4)+
	move.b	#'7',(a4)+
	move.b	#'�',(a4)+
	move.b	#'b',(a4)+
	move.b	#15,(a4)+
	move.b	#225,(a4)+
	move.b	#'M',(a4)+
	move.b	#'a',(a4)+
	move.b	#'i',(a4)+
	move.b	#'n',(a4)+
	move.b	#' ',(a4)+
	move.b	#'M',(a4)+
	move.b	#'e',(a4)+
	move.b	#'n',(a4)+
	move.b	#'u',(a4)+

	add.l	d1,a2
	add.l	#20,a2
	add.l	#8,a2
	move.l	#0,(a2)+		;spec lw
	move.b	#0,(a4)+
	move.l	menyerna,prev

	lea	types_dir,a0
	lea	space,a1
	lea	typesfiler,a6
	lea	uleadrs,a3
.loop:	move.l	a3,-(sp)
	move.l	(a3),a3
	move.l	a2,(a3)
	bsr.s	subrutin
	move.l	(sp)+,a3
	addq.l	#4,a3
	addq.l	#2,a0
	add.l	#400,a6
	lea	space,a1
	tst.w	(a0)
	bne.s	.loop

	cmp.b	#'1',ch_1
	bne.s	E_CH
	cmp.b	#'2',ch_2
	bne.s	E_CH
	cmp.b	#'3',ch_3
	bne.s	E_CH
	cmp.b	#'4',ch_4
	bne.s	E_CH
	cmp.b	#'5',ch_5
	bne.s	E_CH
	cmp.b	#'6',ch_6
	bne.s	E_CH
	move.l	menyerna,d0
	rts
E_CH:	move.w	#-1,d0
.blink:	move.w	#$ff0,$dff180
	dbf	d0,.blink
	move.l	menyerna,d0
	rts

subrutin:
	move.l	a4,this_ms
	moveq	#-1,d1
	moveq	#0,d2
	move.l	#0,next
	move.l	menyerna,prev
	move.w	#0,pagenr
FixLoop:
	move.l	(a1),a3
	move.w	(a3),d0
	bclr	#5,d0
	bclr	#13,d0
	cmp.w	(a0),d0
	bne.w	.next
	addq.l	#1,d1
	bne.s	.ule
.ny:	move.l	a4,(a2)
	move.l	#-1,4(a2)
	move.l	a6,d0
	add.l	#80,a6
.floop:	move.b	(a6)+,(a4)+
	bne.s	.floop
	subq.l	#1,a4
	lea	pagesnack,a3
.fl2:	move.b	(a3)+,(a4)+
	bne.s	.fl2
	subq.l	#1,a4
	move.b	pagenr+1,d7
	add.b	d7,-3(a4)
.fl3:	move.b	(a6)+,(a4)+
	bne.s	.fl3
	subq.l	#1,a4
	move.l	d0,a6

.ule:	cmp.b	#ANT_BAN_MENY,d1
	beq.w	.nymeny
	move.l	d1,d7
	add.l	#1,4(a2)
	move.l	d1,d6
	mulu	#20,d1
	move.l	#65,8(a2,d1.l)
	mulu	#9,d6
	add.l	#53,d6
	move.l	d6,12(a2,d1.l)
	move.l	#10,16(a2,d1.l)		;LOAD!
	move.l	(a1),20(a2,d1.l)
	move.l	a6,24(a2,d1.l)		;leveltypenameptr
	move.b	#'�',(a4)+
	move.b	#'b',(a4)+
	move.b	#65,(a4)+
	move.b	d6,(a4)+
	move.l	(a1),a3
	move.l	d7,d1
	addq.l	#2,a3
.fl123:	move.b	(a3)+,(a4)+
	cmp.b	#'(',-1(a4)
	beq.s	.race
	cmp.b	#'.',-1(a4)
	bne.s	.fl123
	bra.s	.ready_f
.race:	move.b	#'�',-2(a4)
	move.b	#'x',-1(a4)
	move.b	#39,(a4)+
	move.b	#'(',(a4)+
	move.b	#'R',(a4)+
	move.b	#'a',(a4)+
	move.b	#'c',(a4)+
	move.b	#'e',(a4)+
	move.b	#')',(a4)+
	bra.s	.next
.ready_f:
	subq.l	#1,a4
.next:	add.l	#8,a1
	tst.l	(a1)
	bne.w	fixloop

	add.l	#1,4(a2)
	addq.l	#1,d1
	mulu	#20,d1
	move.l	#15,8(a2,d1.l)	;xpos,prev
	move.l	#225,12(a2,d1.l)	;ypos,prev
	move.l	#nymeny,16(a2,d1.l)	;funktion
	move.l	prev,20(a2,d1.l)	;adr till f�rra
	move.l	#0,24(a2,d1.l)
	lea	prevtxt,a3
.flq:	move.b	(a3)+,(a4)+
	bne.s	.flq
	subq.l	#1,a4
	move.b	#0,(a4)+

	add.l	d1,a2
	add.l	#28,a2
	move.l	return,d0
	move.l	d0,(a2)+		;spec lw

	movem.l	d0-d7/a0-a6,-(sp)

	move.w	pagenr,d0
	add.b	#'1',d0
	move.l	this_ms,a0
.seek:	cmp.b	#'P',(a0)
	bne.s	.not
	cmp.b	#'a',1(a0)
	bne.s	.not
	cmp.b	#'/',6(a0)
	bne.s	.not
	move.b	d0,7(a0)
.not:	addq.l	#1,a0
	cmp.l	a0,a4
	bpl.s	.seek

	movem.l	(sp)+,d0-d7/a0-a6

	RTS


.nymeny:
	add.l	#2,4(a2)
	mulu	#20,d1
	move.l	#15,8(a2,d1.l)	;xpos,prev
	move.l	#225,12(a2,d1.l)	;ypos,prev
	move.l	#nymeny,16(a2,d1.l)	;funktion
	move.l	prev,20(a2,d1.l)	;adr till f�rra
	move.l	#0,24(a2,d1.l)
	lea	prevtxt,a3
.fl19:	move.b	(a3)+,(a4)+
	bne.s	.fl19
	subq.l	#1,a4
	lea	nexttxt,a3
.fl20:	move.b	(a3)+,(a4)+
	bne.s	.fl20
	move.l	a2,d0
	add.l	d1,d0
	add.l	#20+20+8+4,d0
	move.l	#140,28(a2,d1.l)	;xpos,next
	move.l	#225,32(a2,d1.l)	;ypos,next
	move.l	#nymeny,36(a2,d1.l)	;funktion
	move.l	d0,40(a2,d1.l)		;adr till n�sta
	move.l	#0,44(a2,d1.l)
	move.l	a2,prev
	move.l	d0,a2
	move.l	return,d0
	move.l	d0,-4(a2)
	moveq	#0,d1
	add.w	#1,pagenr
	bra.w	.ny


READ:		EQU	-42	;d1/d2/d3 fileh/buffer/length
WRITE:		EQU	-48	;d1/d2/d3 fileh/buffer/length
ALLOC:		EQU	-198	;d0/d1 size/req <d0>
FREEMEM:	EQU	-210	;a1/d0 adr/size
;req = chip $2,fast $4,clear $10000


	fname:		dc.l	0	;temp...
	flock:		dc.l	0	;temp...
	finfoblock:	dc.l	0	;all of them...
	fsize:		dc.l	0
	fhandle:	dc.l	0
	fmem:		dc.l	0	
loadfile:		;autodoc: a0 ptr to 0-t filename.d0 returns
			; adr,d1 size d0=0? fail
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	a0,fname
	move.l	dosbase,a6
	move.l	d0,fmem
	move.l	fname,d1
	move.l	#$3ed,d2
	jsr	open(a6)
	move.l	d0,fhandle
	move.l	d0,d1
	move.l	#400,d3
	move.l	fmem,d2
	jsr	read(a6)
	move.l	fhandle,d1
	jsr	close(a6)
	movem.l	(sp)+,d2-d7/a0-a6
	move.l	fmem,d0
	move.l	fsize,d1
	rts
;-------

return:		dc.l	0
filerna:	dc.l	0
menyerna:	dc.l	0
texterna:	dc.l	0
DOSBASE:	DC.L	0
DOSNAME:	DC.B	'dos.library',0
EVEN
DIRNAME:	DC.B	'GPX:Levels/',0	; Namn f�r l�sning
typesname:	
	dc.b	'GPX:Types/',0
pagesnack:	dc.b	'�b',130,25,'�fFPage 1/1',0

nexttxt:	dc.b	'�b',140,225,'�f7Next',0
prevtxt:	dc.b	'�b',15,225,'�f7Previous',0
inittext:	dc.b	'�b',62,30,'�D�f2Select Level Type�n',0
	EVEN
filtemp:	dc.b	'GPX:Types/xx',0,0
prev:	dc.l	0
next:	dc.l	0
pagenr:	dc.w	0
this_ms:	dc.l	0

NOFILES:	dc.l	0
DIRLOCK:	DC.L	0

	section meno,bss

INFO:		ds.l	66
FILES:		ds.l	MAXFILES*9
menyer:		ds.l	MAXFILES*6
space:		ds.l	MAXFILES*2
text:		ds.l	MAXFILES*6
types_dir:	ds.l	MAXTYPES
typesfiler:	ds.l	MAXTYPES*100
uleadrs:	ds.l	25


CH_1:		equ	FILES+MAXFILES*36-200
CH_2:		equ	MENYER+MAXFILES*24-100
CH_3:		equ	SPACE+MAXFILES*8-100
CH_4:		equ	TEXT+MAXFILES*24-100
CH_5:		equ	typesfiler+MAXTYPES*400-100
CH_6:		equ	uleadrs+80

