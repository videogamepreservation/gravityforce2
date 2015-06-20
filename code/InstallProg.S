
	section		BiTS,code
	
OPENLIBRARY:	EQU	-408	; a1 libname <d0>
CLOSELIBRARY:	EQU	-414	; a1 base
OPEN:		EQU	-30
		; d1/d2 filen/accessm($3ed=existing,$3ee=new) <d0>
CLOSE:		EQU	-36	; d1 fileh
LOCK:		EQU	-84	; d1/d2 lock/type(-2 = read) <d0>
UNLOCK:		EQU	-90	; d1 lock
EXAMINE:	EQU	-102	; d1/d2 lock/fileinfoblock <0=dir empty>
EXNEXT:		EQU	-108	; d1/d2 dirlock/fileinfoblock <0=last>
INPUT:		EQU	-54	; () <d0>
OUTPUT:		EQU	-60	; () <d0>
READ:		EQU	-42	;d1/d2/d3 fileh/buffer/length
WRITE:		EQU	-48	;d1/d2/d3 fileh/buffer/length
ALLOC:		EQU	-198	;d0/d1 size/req <d0>
FREEMEM:	EQU	-210	;a1/d0 adr/size
;req = chip $2,fast $4,clear $10000

;Ex: från cli: Urk Ule
; a0 pekar på adr 87
; adr 87: 'Ule',10

progg:
	cmp.b	#11,(a0)
	bls.w	felquit
	lea	filnamn,a1
.l:	move.b	(a0)+,(a1)+
	cmp.b	#11,(a0)
	bhi.s	.l
	move.b	#0,(a1)

	bsr	opendos
	tst.w	d0
	bne.w	felquit
	
	lea	helptext,a0
	bsr	typetxt

	move.l	dosbase,a6
	move.l	dos_in,d1
	move.l	#path,d2
	moveq	#100,d3
	jsr	read(a6)

	lea	path,a0
	cmp.b	#11,(a0)
	bls.w	felquit2
	moveq	#-1,d0
.q:	addq.l	#1,d0
	cmp.b	#11,(a0)+
	bhi.s	.q
	subq.l	#2,a0
	cmp.b	#':',(a0)
	beq.s	.nix
	cmp.b	#'/',(a0)
	beq.s	.nix
	addq.l	#1,a0
	move.b	#'/',(a0)
.nix:	addq.l	#1,a0
	lea	gf2,a1
.pq:	move.b	(a1)+,(a0)+
	bne.s	.pq

	lea	qqq1,a0
	lea	fil2,a1
	move.l	fsize,d0
.qq:	addq.l	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.qq
	lea	path,a2
	subq.l	#1,a1
	subq.l	#1,d0
.ww:	addq.l	#1,d0
	move.b	(a2)+,(a1)+
	bne.s	.ww
	subq.l	#1,a1
	subq.l	#1,d0
.ee:	addq.l	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.ee
	move.b	#10,-1(a1)

	move.l	d0,fsize
	move.l	#filnamn2,d1
	bsr	savefile

	lea	qqq2,a0
	lea	filen,a1
.ii:	move.b	(a0)+,(a1)+
	bne.s	.ii
	subq.l	#1,a1
	lea	path,a2
.u:	move.b	(a2)+,(a1)+
	bne.s	.u
	subq.l	#2,a1
.y5:	move.b	(a0)+,(a1)+
	bne.s	.y5
	subq.l	#1,a1
	lea	path,a2
.rt5:	move.b	(a2)+,(a1)+
	bne.s	.rt5
	subq.l	#2+3-1,a1
;.y:	move.b	(a0)+,(a1)+
;	bne.s	.y
;	subq.l	#1,a1
;	lea	path,a2
;.rt:	move.b	(a2)+,(a1)+
;	bne.s	.rt
;	subq.l	#2,a1
;.by:	move.b	(a0)+,(a1)+
;	bne.s	.by
;	subq.l	#1,a1
;	lea	path,a2
;.ut:	move.b	(a2)+,(a1)+
;	bne.s	.ut
;	subq.l	#2,a1
;.iy:	move.b	(a0)+,(a1)+
;	bne.s	.iy
;	subq.l	#1,a1
;	lea	Path,a2
;.ot:	move.b	(a2)+,(a1)+
;	bne.s	.ot
;	subq.l	#2,a1
;.py:	move.b	(a0)+,(a1)+
;	bne.s	.py
	move.b	#10,-1(a1)
	move.b	#0,(a1)

	lea	filen,a0
	moveq	#-1,d0
.rr:	addq.l	#1,d0
	tst.b	(a0)+
	bne.s	.rr

	move.l	d0,fsize
	move.l	#filnamn,d1
	move.l	#filen,fmem
	bsr	savefile

	move.l	dosbase,a6
	jsr	output(a6)
	move.l	d0,dos_out
	lea	wait_txt,a0
	bsr	typetxt

quit:	bsr	close_con
	moveq	#0,d0
	rts

felquit2:
	bsr	close_con
felquit:
	moveq	#20,d0
	rts

	fmem:		dc.l	fil2
savefile:
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	dosbase,a6

	move.l	#$3ee,d2
	jsr	open(a6)
	tst.l	d0
	beq.s	.fail
	move.l	d0,fhandle
	move.l	d0,d1
	move.l	fsize,d3
	move.l	fmem,d2
	jsr	write(a6)
	move.l	fhandle,d1
	jsr	close(a6)
	movem.l	(sp)+,d2-d7/a0-a6
	moveq	#1,d0
	rts
.fail:
	movem.l	(sp)+,d2-d7/a0-a6
	moveq	#0,d0
	rts
	
typetxt:		;autodoc: a0 ptr to 0-terminated txt
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,d2
.loop:	tst.b	(a0)+
	bne.s	.loop
	move.l	a0,d3
	sub.l	d2,d3
	subq.l	#1,d3
	move.l	dos_out,d1
	move.l	dosbase,a6
	jsr	write(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
		
opendos:
	lea	dosname,a1
	move.l	4,a6
	jsr	openlibrary(a6)
	move.l	d0,dosbase
	beq.s	.exit
	move.l	d0,a6
	move.l	#conname,d1
	move.l	#$3ed,d2
	jsr	open(a6)
	tst.l	d0
	beq.s	.exit
	move.l	d0,dos_in
	move.l	d0,dos_out
	moveq	#0,d0
	rts

	move.l	d0,fhandle
	jsr	input(a6)
	move.l	d0,dos_in
	beq.s	.exit
	jsr	output(a6)
	move.l	d0,dos_out
	beq.w	.exit
.exit:
	moveq	#1,d0
	rts
		
close_con:
	move.l	dos_in,d1
	beq.s	.ut
	move.l	dosbase,a6
	jsr	close(a6)
	move.l	a6,a1
	move.l	4,a6
	jsr	closelibrary(a6)
.ut:	rts

;-------
dosname:	dc.b	'dos.library',0
conname:	dc.b	'CON:000/050/640/100/GF2',0
wait_txt:	dc.b	10,'Please wait, installing GF2...',10,0
helptext:	dc.b	10,$9b,'33m GravityForce 2 Installer',$9b,'31m',10
	dc.b	10,'In which directory should GF2 be installed?',10
	dc.b	' Examples: dh0: or dh0:MyGames/',10,10
	dc.b	'Enter path: ',0
qqq1:	dc.b	'assign GF2: ',0
	dc.b	'GF2:GF.exe',0
qqq2:	dc.b	'copy /GF2 ',0
	dc.b	' all quiet',10
	dc.b	'copy /GF2.info ',0,10
	dc.b	'copy ram:Start_GF2 ',0,0
	
filnamn2:	dc.b	'ram:Start_GF2',0

gf2:	dc.b	'GF2',10,0
	section sdf,bss

path:	ds.b	50
filen:	ds.b	100
fil2:	ds.b	100
filnamn:	ds.b	30
fsize:		ds.l	1
fhandle:	ds.l	1
dosbase:	ds.l	1
dos_in:		ds.l	1
dos_out:	ds.l	1

