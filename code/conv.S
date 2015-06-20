ùúùúÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·ÿ;¶·

;starta. ligger på data - data+size

size:	equ	21974

prog:
	move.l	#size,d0
	move.l	data,result
	lea	result+4,a1
	lea	data+4,a0
.fbl:	move.b	(a0)+,(a1)+
	bne.s	.fbl
	lea	result+29,a1
	lea	data+29,a0
.fbl2:	move.b	(a0)+,(a1)+
	bne.s	.fbl2
	sub.l	#54,d0
	sub.l	#32,d0
	divu	#4,d0
	and.l	#$ffff,d0
	lea	data+54,a0
	lea	sd1,a1
	lea	sd1,a2
	lea	sd1,a3
	lea	sd1,a4
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a3
	add.l	d0,a4
	add.l	d0,a4
	add.l	d0,a4
	lea	sd1,a5
	add.l	d0,a5
	add.l	d0,a5
	add.l	d0,a5
	add.l	d0,a5
	move.l	d0,d7
	lsr.l	#1,d7
	subq.l	#1,d7
.l:	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a2)+
	move.w	(a0)+,(a3)+
	move.w	(a0)+,(a4)+
	dbf	d7,.l
	moveq	#15,d7
.l2:	move.w	(a0)+,(a5)+
	dbf	d7,.l2
	rts

result:
	blk.b	54,0
sd1:	blk.b	25000,0

data:	incbin	"gf2:gfx/desert.bmap"
