ùúùúÿ<Gÿ<Gÿ<Gÿ<Gÿ<Gÿ<Gÿ<Gÿ<Gÿ<G
	section	bits,code

	move.l	a0,d7
	bsr	opendos
	move.l	d7,a0

reada0:
	moveq	#1,d5
	cmp.b	#'-',(a0)
	bne.s	.apos
	addq.l	#1,a0
	moveq	#-1,d5
.apos:	bsr	atd
	addq.l	#1,a0
	muls	d5,d0
	move.l	d0,adat

	moveq	#1,d5
	cmp.b	#'-',(a0)
	bne.s	.bpos
	addq.l	#1,a0
	moveq	#-1,d5
.bpos:	bsr	atd
	addq.l	#1,a0
	muls	d5,d0
	move.l	d0,bdat

	move.l	adat,d0
	move.l	bdat,d1
	bsr	atn

	lea	buf,a0
	bsr	dta

	lea	buf,a0
	bsr	typetxt
	rts

dta:	move.l	d0,d7
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)
	sub.b	#'0',d0
	mulu	#10,d0
	sub.b	d0,d7
	add.b	#'0',d7
	move.b	d7,1(a0)
	move.b	#10,2(a0)
	move.b	#0,3(a0)
	rts

atd:	moveq	#2,d7
	moveq	#100,d6
	moveq	#0,d1
.read:	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	mulu	d6,d0
	add.w	d0,d1
	divu	#10,d6
	and.l	#$FFF,d6
	dbf	d7,.read
	move.w	d1,d0
	rts


OPENLIBRARY:	EQU	-408	; a1 libname <d0>
OUTPUT:		EQU	-60	; () <d0>
WRITE:		EQU	-48	;d1/d2/d3 fileh/buffer/length

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
	jsr	output(a6)
	move.l	d0,dos_out
	beq.w	.exit
.exit:	moveq	#0,d0
	rts

dosname:	dc.b	'dos.library',0
dosbase:	dc.l	0
dos_out:	dc.l	0

atn:	;autodoc: d0.w=a,d1.w=b result: d0=atan(a/b)
	moveq	#0,d7
	moveq	#0,d5
	tst.w	d0
	bpl.s	.apos
	neg.l	d0
	not.b	d7
.apos:	tst.w	d1
	bpl.s	.bpos
	neg.l	d1
	not.b	d7
	beq.s	.48
	bra.s	.00
.bpos:	tst.b	d7
	beq.s	.16
.32:	moveq	#32,d6
	bra.s	.cont
.48:	moveq	#48,d6
	bra.s	.cont
.16:	moveq	#16,d6
	bra.s	.cont
.00:	moveq	#0,d6
.cont:	cmp.w	d0,d1
	beq.s	.atn8
	bpl.s	.norm
	exg	d0,d1
	not.b	d7
.norm:	swap	d0
	tst.w	d1
	beq.s	.noll
	divu	d1,d0
	lsr.w	#8,d0
	lsr.w	#2,d0
	lea	arctan,a0
	move.b	(a0,d0.w),d5
.ok:	tst.b	d7
	bne.s	.ready
	moveq	#16,d7
	sub.w	d5,d7
	add.w	d7,d6
	move.l	d6,d0
	rts
.ready:	add.w	d5,d6
	move.l	d6,d0
	rts
.atn8:	move.l	d6,d0
	addq.l	#8,d0
	rts
.noll:	moveq	#0,d5
	bra.s	.ok

arctan:	incbin	"ram:arctan.dat"

adat:	dc.l	0
bdat:	dc.l	0
buf:	dc.l	0
param:	dc.b	'001 -001',0
