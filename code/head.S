שתשתÿ<Vÿ<Vÿ<Vÿ<Vÿ<Vÿ<Vÿ<Vÿ<Vÿ<V
;	.bmap header

size:	equ	54

j:
	lea	skap,a0
	lea	skap_pl,a1
.n:	move.b	(a0)+,(a1)+
	bne.s	.n
	lea	namn,a0
	lea	namn_pl,a1
.n2:	move.b	(a0)+,(a1)+
	bne.s	.n2
	rts

skap:	dc.b	'Skapare',0
namn:	dc.b	'TypNamn',0


data:
	dc.b	'GBM',0
namn_pl:
	blk.b	25,0
skap_pl:
	blk.b	25,0
slut:

