����������  "�������������������
;Pm;og ST...

	section snix,code

start:	cmp.w	#0,d7
	beq.w	nytt
	cmp.w	#1,d7
	beq.s	.save_log
	cmp.w	#2,d7
	beq.w	chk_checksum
	cmp.w	#3,d7
	beq.w	fixa_txt
	cmp.w	#4,d7
	beq.w	upd_stat
	cmp.w	#5,d7
	beq.w	upd_binfo
	cmp.w	#6,d7
	beq.w	rita_bana
	cmp.w	#7,d7
	beq.w	unp_data
	cmp.w	#8,d7
	beq.w	rita_bild
	cmp.w	#9,d7
	beq.s	save_prefs
	rts
.save_log:
	move.l	(a1),fmem
	move.l	(a1),a0
	addq.l	#1,16(a0)	;antal startningar
	move.l	40(a0),d0
	mulu	#50,d0
	add.l	#44,d0
	move.l	d0,fsize
;	move.l	#'RAM:',fname
;	bsr	savefile
	bsr	fix_chksum
	bsr	code
;	move.l	#'GF2:',fname
	move.l	#fname,d1
	bsr	savefile
	rts

save_prefs:
	move.l	a5,fmem
	move.l	#fname2,d1
	move.l	#480,fsize
	bsr	savefile
	move.l	12(a1),a6
	moveq	#100,d1
	jsr	-198(a6)	;delay
	rts

bifmeny1:
	dc.l	binfo,0
	dc.l	15,225,0
home1:	dc.l	bifmeny1,0
	dc.l	0,0,0

bifmeny2:
	dc.l	binfo,1
	dc.l	15,225,0
home2:	dc.l	bifmeny2,0
	dc.l	124,225,0,yon,0
	dc.l	0,0,0

yon:	dc.l	yontxt,1
	dc.l	100,116,0,bifmeny2,0
	dc.l	60,116,192,'BITS','SNIX'
	dc.l	bifmeny2,0,0

yontxt:
	dc.b	'�y',70,'�D�z�f7Clear the Record???�b',60,120
	dc.b	'�f1Yes�x',100,'�f2No!',0

binfo:	dc.b	'�y',30,'�d�z�f7Level Info�n�b',20,50,'�f5Level�p:�x',70,'�g'
	even
lvl:	dc.l	spist
	dc.b	10,'�x',20,'�f5Creator�p:�x',70,'�g'
	even
skap:	dc.l	0
	dc.b	10,'�x',20,10,'�f2Level Type�p:�x',70,'�g'
	even
typ_l:	dc.l	0
	dc.b	10,'�x',20,'�f2GFX by�p:�x',70,'�g'
	even
typ_g:	dc.l	0
	dc.b	10,10,'�x',20,'�f3Size, pixels�p:�x',70,'�g'
	even
bana_s:	dc.l	0
	dc.b	10,'�x',20,'�f3Structure�p:�x',70,'�g'
	even
bana_t:	dc.l	0
	dc.b	10,'�x',20,'�f3Compression�p:�x',70,'�g'
	even
bana_p:	dc.l	0
	dc.b	10,10,10,'�g'
	even
studs:	dc.l	0
cont:	dc.b	'�b',15,225,'�f7OK!'
gronk:	dc.b	'�x',124,'�f1Clear Record',0

upname:	dc.b	'Nobody',0
	even
uleply:	dc.l	$3a98,$3a98,$3a98
pack_rate:	dc.l	0

upd_binfo:
	move.l	-20(a1),typ_l
	sub.l	#50,typ_l
	move.l	-20(a1),typ_g
	sub.l	#25,typ_g
	move.l	-4(a1),pack_rate
	tst.w	d0
	beq.s	.g
	move.l	a4,Home1
	move.b	#0,gronk
	move.l	#cont,studs
	bra.s	.q
.g:	move.l	a4,Home2
	move.b	#'�',gronk
	move.l	#res_txt,studs
	move.l	#upname,8(a1)
	move.l	#uleply,4(a1)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	nytt
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	fixa_txt
	movem.l	(sp)+,d0-d7/a0-a6
.q:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	check_btyp
	move.l	a0,bana_t
	move.l	a1,bana_s
	move.l	a5,bana_p
	movem.l	(sp)+,d0-d7/a0-a6

	addq.l	#4,a2
	move.l	a2,skap
	addq.l	#2,a3
	lea	spist,a2
.l:	cmp.b	#'.',(a3)
	beq.s	.ut
	move.b	(a3)+,(a2)+
	bra.s	.l
.ut:	move.b	#0,(a2)

	cmp.l	#t_iff,bana_t
	bne.s	.q2
	move.l	#t_iff,typ_l
	move.l	skap,typ_g
.q2:
	lea	bifmeny1,a0
	tst.w	d0
	bne.s	.out
	lea	b_lap,a1
	move.b	#'3',-4(a1)
	lea	b_total,a1
	move.b	#'3',-4(a1)
	lea	bifmeny2,a0
.out:
	rts

upd_stat:
	move.l	a1,a6
	bsr	fixa_stat
	rts

check_btyp:
	moveq	#100,d0
	sub.w	pack_rate+2,d0
	divu	#10,d0
	move.b	d0,rate_txt+2
	swap	d0
	move.b	d0,rate_txt+3
	add.b	#'0',rate_txt+2
	add.b	#'0',rate_txt+3
	lea	p_none,a5
	tst.w	pack_rate+2
	beq.s	.not_packed
	lea	p_unk,a5
	cmp.w	#0,pack_rate
	bne.s	.not_packed
	lea	p_bpck1,a5
.not_packed:
	cmp.l	#'GFB!',(a2)
	bne.s	.n0
	lea	t_block,a0
	lea	s_norm,a1
	rts
.n0:
	cmp.l	#'GFIF',(a2)
	bne.s	.n1
	move.l	134(a2),d0
	add.l	#138,d0
	move.l	126(a2),d1
	mulu	#42*4,d1
	lsr.l	#8,d1
	lsr.l	#8,d0
	mulu	#100,d0
	divu	d1,d0
	and.l	#$ffff,d0
	moveq	#100,d1
	sub.b	d0,d1
	divu	#10,d1
	move.b	d1,rate_txt+2
	swap	d1
	move.b	d1,rate_txt+3
	add.b	#'0',rate_txt+2
	add.b	#'0',rate_txt+3
	lea	s_iff+4,a1
	moveq	#0,d1
	move.l	126(a2),d0
	bsr	contdec
	move.b	#0,(a1)
	lea	t_iff,a0
	lea	s_iff,a1
	lea	p_iffp,a5
	rts
.n1:
	lea	t_unk,a0
	lea	s_unk,a1
	rts

t_block:	dc.b	'Block',0
s_norm:		dc.b	'336x1008',0
t_unk:		dc.b	'<Unknown>',0
s_unk:		dc.b	'<Unknown>',0
t_iff:		dc.b	'IFF',0
s_iff:		dc.b	'336xY',0,0,0,0,0
p_none:		dc.b	'None',0
p_iffp:		dc.b	'IFF Type 1�j'
		even
		dc.l	rate_txt
p_bpck1:	dc.b	'BPCK�j'
		even
		dc.l	rate_txt
p_unk:		dc.b	'<Unknown>',0
	even
rate_txt:	dc.b	' (xx% gain)',0
	even

magn_off:	dc.l	0
shoot_off:	dc.l	0

fixa_txt:
	move.l	a1,a6
;	move.l	20(a1),a2
;	move.l	#b_total,a0
;	bsr	fix_name
;	move.l	24(a1),a3
;	move.l	#b_lap,a0
;	bsr	fix_name
.no_new:
	move.l	senaste,a4
	move.l	28(a6),a5	;frac d0=> (a1)+
	moveq	#2,d7
	lea	v_tider,a1
	addq.l	#2,a4
.gl:	moveq	#0,d0
	move.w	(a4)+,d0
	move.l	d7,-(sp)
	jsr	(a5)
	move.l	(sp)+,d7
	move.b	#'-',(a1)+
	dbf	d7,.gl
	move.b	#')',-(a1)
	move.b	#0,1(a1)
	move.l	senaste,a0
	moveq	#0,d0
	add.w	2(a0),d0
	add.w	4(a0),d0
	add.w	6(a0),d0
	lea	b_total,a1
	move.b	#'3',-4(a1)
	tst.l	20(a6)
	beq.s	.qw
	move.b	#'4',-4(a1)
.qw:	jsr	(a5)
	move.b	#0,(a1)
	moveq	#0,d0
	move.l	senaste,a0
	move.w	28(a0),d0
	lea	b_lap,a1
	move.b	#'3',-4(a1)
	tst.l	24(a6)
	beq.s	.we
	move.b	#'4',-4(a1)
.we:	jsr	(a5)
	move.b	#0,(a1)
	move.l	senaste,a0
	lea	8(a0),a1
	lea	30(a0),a2
	move.l	a1,n_t
	move.l	a2,n_l
	lea	res_txt,a0
	rts

res_txt:
	dc.b	'�x',15,'�f7Record Times:',10,'�g'
	even
	dc.l	r_lap
	dc.b	'�x',64,' �g'
n_l:	dc.l	0
	dc.b	'�f0',10,'�g'
	even
	dc.l	r_total
	dc.b	'�x',64,' �g'
n_t:	dc.l	0
	dc.b	10,' (�g'
	even
	dc.l	v_tider
	dc.b	0

r_lap:		dc.b	'�x',20,'�f3Lap�p:�f3�r',60
b_lap:		blk.b	12,0
r_total:	dc.b	'�x',20,'�f3Total�p:�f3�r',60
b_total:	blk.b	12,0
	odd
times_t:dc.b	' times.',0
	even

stat_txt:
	dc.b	'�x',10,'�f7Statistics�p:�f0',10
	dc.b	'�f2 GP started �g'
	even
	dc.l	s_times
	dc.b	10,'�r',115,'Total�r',140,'Today',10,'�x',10
	dc.b	' Played Dogfights�p:�g'
	even
	dc.l	s_matcher
	dc.b	'�g'
	even	
	dc.l	s_matcher2
	dc.b	10,'�x',10,' Played Races�p:�g'
	even
	dc.l	s_races
	dc.b	'�g'
	even	
	dc.l	s_races2
	dc.b	10,'�x',10,' Matches >20 sec�p:�g'
	even
	dc.l	s_lmatch
	dc.b	'�g'
	even
	dc.l	s_lmatch2
	dc.b	10,'�x',10,' Rounds fired�p:�g'
	even
	dc.l	s_rounds
	dc.b	'�g'
	even
	dc.l	s_rounds2
	dc.b	10,10,'�x',10,' Total Effective Playtime�p: �g'
	even
	dc.l	s_playt
	dc.b	10,'�x',10,' Playtime Today�p: �g'
	even
	dc.l	s_playt2

	dc.b	0

	odd
t_hour:	dc.b	' hour'
pl_aend:	dc.b	's ',0

minuter:	dc.b	' minutes',0
minut:	dc.b	' minute',0

	even
fixa_stat:
	lea	kopia,a5
	move.l	(a6),a0
	move.l	4(a0),d0
	sub.l	24(a0),d0
	lea	s_matcher,a1
	moveq	#115,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	4(a0),d0
	sub.l	4(a5),d0
	move.l	24(a0),d1
	sub.l	24(a5),d1
	sub.l	d1,d0
	moveq	#115,d1
	lea	s_matcher2,a1
	move.l	#140,d1
	bsr	contdec
	move.b	#0,(a1)
	lea	s_playt,a1
	move.l	8(a0),d0
	move.b	#'�',(a1)+
	move.b	#'r',(a1)+
	move.b	#140,(a1)+
	bsr.w	t_fix
	move.b	#0,(a1)
	lea	s_playt2,a1
	move.l	8(a0),d0
	sub.l	8(a5),d0
	move.b	#'�',(a1)+
	move.b	#'r',(a1)+
	move.b	#140,(a1)+
	bsr.w	t_fix
	move.b	#0,(a1)
	move.l	16(a0),d0
	moveq	#0,d1
	addq.l	#1,d0
	lea	s_times,a1
	bsr	contdec
	lea	times_t,a2
	move.w	#'s.',times_t+5
	tst.l	16(a0)
	bne.s	.cfl
	move.w	#$2e00,times_t+5
.cfl:	move.b	(a2)+,(a1)+
	bne.s	.cfl
	move.l	12(a0),d0
	lea	s_rounds,a1
	move.l	#115,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	12(a0),d0
	sub.l	12(a5),d0
	lea	s_rounds2,a1
	move.l	#140,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	20(a0),d0
	lea	s_lmatch,a1
	move.l	#115,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	20(a0),d0
	sub.l	20(a5),d0
	lea	s_lmatch2,a1
	move.l	#140,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	24(a0),d0
	lea	s_races,a1
	move.l	#115,d1
	bsr	contdec
	move.b	#0,(a1)
	move.l	24(a0),d0
	sub.l	24(a5),d0
	lea	s_races2,a1
	move.l	#140,d1
	bsr	contdec
	move.b	#0,(a1)
	rts

t_fix:	add.l	#1500,d0
	divu	#3000,d0
	and.l	#$ffff,d0
	divu	#60,d0
	tst.w	d0
	bne.s	.hours
	swap	d0
	bra.s	.no_h
.hours:	move.l	d0,d5
	and.l	#$ffff,d0
	move.w	#'s ',pl_aend
	cmp.w	#1,d0
	bhi.s	.ok
	move.w	#$2000,pl_aend
.ok:	moveq	#0,d1
	bsr	contdec
	lea	t_hour,a2
.l:	move.b	(a2)+,(a1)+
	bne.s	.l
	subq.l	#1,a1
	move.l	d5,d0
	swap	d0
	and.l	#$ffff,d0
	beq.s	.no_mi
.no_h:	move.l	d0,d5
	moveq	#0,d1
	bsr	contdec
	cmp.w	#1,d5
	beq.s	.ental
	lea	minuter,a2
.l2:	move.b	(a2)+,(a1)+
	bne.s	.l2
	subq.l	#1,a1
	bra.s	.ut
.ental:	lea	minut,a2
.l3:	move.b	(a2)+,(a1)+
	bne.s	.l3
	subq.l	#1,a1	
.ut:	move.b	#0,(a1)+
	rts
.no_mi:	move.b	#0,-(a1)
	rts

contdec:	;d0=#xxxxxx,a1=ptr
	tst.b	d1
	beq.s	.p
	move.b	#'�',(a1)+
	move.b	#'r',(a1)+
	move.b	d1,(a1)+
.p:	tst.l	d0
	beq.s	.noll
	move.w	#0,cd_snix
	move.l	#100000,d1
.l:	cmp.l	d0,d1
	bhi.s	.n
	move.w	#-1,cd_snix
	moveq	#'0',d2
.q:	addq.b	#1,d2
	sub.l	d1,d0
	cmp.l	d1,d0
	bpl.s	.q
	move.b	d2,(a1)+
	bra.s	.nn
.n:	tst.w	cd_snix
	beq.s	.nn
	move.b	#'0',(a1)+
.nn:	divu	#10,d1
	and.l	#$ffff,d1
	bne.s	.l
	rts
.noll:	move.b	#'0',(a1)+
UT:	rts

rita_bana:
	move.l	a5,podadr
	move.l	#0,-4(a1)
	move.l	a1,a6
	move.l	4(a6),a0
	move.l	8(a6),a1
	move.l	(a6),a2			;bpl 1...4
	move.l	a2,a3
	move.l	a2,a4
	move.l	a2,a5
	move.l	12(a6),d6
	add.l	d6,a3
	add.l	d6,a4
	add.l	d6,a4
	add.l	d6,a5
	add.l	d6,a5
	add.l	d6,a5
	sub.l	#130,a0
	cmp.l	#'GFIF',(a0)
	beq.w	gfifrit
	cmp.l	#'GFB!',(a0)
	bne.s	UT
	add.l	#130,a0
	moveq	#62,d0	;62+1 block h�gt
Loop1:	moveq	#20,d1		;20+1 block brett
Loop2:	moveq	#15,d2		;15+1 pix h�ga block
	moveq	#0,d3
	move.b	(a0)+,d3
	moveq	#0,d4
	tst.b	d3
	beq.s	spacy
	cmp.b	#250,d3
	bls.s	.ok
	sub.b	#250,d3
	move.l	podadr,a1
	moveq	#20,d5
	sub.w	d1,d5
	mulu	#16,d5
	add.w	#15,d5
	move.w	d5,(a1)+
	moveq	#62,d5
	sub.w	d0,d5
	mulu	#16,d5
	add.w	#15,d5
	move.w	d5,(a1)+
	move.w	d3,(a1)+
	move.l	a1,podadr

	lea	pods,a1
.ok:
	subq.b	#1,d3
	asl.l	#7,d3
	add.l	d3,a1
	moveq	#0,d3
Loop3:
	move.w	0(a1),0(a2,d4)		;leveltype -> bpl 1
	move.w	2(a1),0(a3,d4)	;lt bpl2   -> bpl 2
	move.w	4(a1),0(a4,d4)	;lt bpl3   -> bpl 3
	move.w	6(a1),0(a5,d4)	;lt bpl4   -> bpl 4 
	add.l	#42,d4
	addq.l	#8,a1
	dbf	d2,loop3
	move.l	8(a6),a1
	bra.s	next
spacy:
	move.w	#0,(a2,d4)
	move.w	#0,(a3,d4)
	move.w	#0,(a4,d4)
	move.w	#0,(a5,d4)
	add.l	#42,d4
	dbf	d2,spacy

next:
	add.l	#2,a2
	add.l	#2,a3
	add.l	#2,a4
	add.l	#2,a5
	dbf	d1,loop2	;xloopen
	add.l	#42*15,a2	
	add.l	#42*15,a3	;15 (1 rad redan addad med 21* add #2,ax)
	add.l	#42*15,a4
	add.l	#42*15,a5
	dbf	d0,loop1	;yloopen


			;a0 pekar p� shooters-datan
	move.l	20(a6),a1
	moveq	#119,d7		;120bytes
.loop:	move.b	(a0)+,(a1)+
	dbf	d7,.loop

	move.l	16(a6),a1
	moveq	#9,d7		;20bytes
.l2:	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.ut
	moveq	#-1,d1	;-1=h�ger
	btst	#7,d0
	beq.s	.n
	moveq	#1,d1	;1=v�nster
.n:	bclr	#7,d0
	move.w	d1,(a1)+
	subq.l	#1,d0
	mulu	#16,d0
	add.w	#8,d0
	move.w	d0,(a1)+
	moveq	#0,d0
	move.b	(a0)+,d0
	subq.l	#1,d0
	mulu	#16,d0
	move.w	d0,(a1)+
	dbf	d7,.l2
.ut:	move.w	#-2,(a1)+
	rts


inga_shoot_e_magnet:
	move.l	20(a6),a1
	moveq	#119,d7
.loop:	move.b	#0,(a1)+
	dbf	d7,.loop
	move.l	16(a6),a1
	move.w	#-2,(a1)
	rts

gfifrit:
	bsr	inga_shoot_e_magnet
	move.l	126(a0),d7
	asl.l	#2,d7
	subq.l	#1,d7
	moveq	#0,d6
	moveq	#0,d0
	add.l	#130,a0
	move.l	a0,-(sp)
.sl:	addq.l	#2,a0
	cmp.l	#'BODY',(a0)
	bne.s	.sl
	add.l	#8,a0
.loop:	move.b	(a0)+,d0
	bmi.s	.packup
	and.w	#$ff,d0
.loop2:	move.b	(a0)+,(a2)+
	addq.l	#1,d6
	dbf	d0,.loop2
	bra.s	.g
.packup:
	neg.b	d0
	and.w	#$ff,d0
.l3:	move.b	(a0),(a2)+
	addq.l	#1,d6
	dbf	d0,.l3
	addq.l	#1,a0
.g:	cmp.l	#42,d6
	blt.s	.loop
	moveq	#0,d6
	move.l	a2,d0
	move.l	a3,a2
	move.l	a4,a3
	move.l	a5,a4
	move.l	d0,a5
	dbf	d7,.loop
	move.w	#83,d7
.fmn:	move.b	#0,(a2)+
	move.b	#0,(a3)+
	move.b	#0,(a4)+
	move.b	#0,(a5)+
	dbf	d7,.fmn
	move.l	(sp)+,a0
.ll:	addq.l	#2,a0
	cmp.l	#'CMAP',(a0)
	bne.s	.ll
	move.l	a0,-4(a6)
	rts

fix_chksum:
	move.l	fmem,a0
	move.l	fsize,d7
	asr.l	#2,d7
	subq.l	#2,d7
	move.l	a0,a2
	moveq	#0,d1
	addq.l	#4,a0
.cl:	add.l	(a0)+,d1
	dbf	d7,.cl
	neg.l	d1
	eor.l	#'SNIX',d1
	move.l	d1,(a2)
	rts
chk_checksum:
	move.l	d0,-(sp)
	bsr	decode
	move.l	(sp)+,d0
	move.l	(a1),a0
	move.l	(a0)+,d1
	eor.l	#'SNIX',d1
	asr.l	#2,d0
	subq.l	#2,d0
.cl:	add.l	(a0)+,d1
	dbf	d0,.cl
	tst.l	d1
	bne.s	fel_chk
	move.l	(a1),a0
	lea	kopia,a2
	moveq	#6,d7
.l:	move.l	(a0)+,(a2)+
	dbf	d7,.l
	move.l	a1,a6
	move.l	(a1),a0
	bsr	fixa_stat
	move.l	#stat_txt,d0
	move.l	#kopia,d1
	lea	start,a0
	lea	version,a1
	rts
fel_chk:
	move.l	(a1),a0
	add.l	#40,a0
	move.l	(a0)+,d7
	subq.w	#1,d7
.l:	move.l	#$3a983a98,2(a0)
	move.w	#$3a98,6(a0)
	move.w	#$3a98,28(a0)
	add.l	#50,a0
	dbf	d7,.l
	move.l	a1,a6
	bsr	fixa_stat
	move.l	#stat_txt,d0
	rts
decode:
;	rts
	move.l	(a1),a0
	add.l	d0,a0
	subq.l	#2,a0
	asr.l	#1,d0
	subq.l	#2,d0
.l:	move.w	(a0),d1
	eor.w	#'!?',d1
	eor.w	d1,-2(a0)
	subq.l	#2,a0
	dbf	d0,.l
	rts
code:
;	rts
	move.l	(a1),a0
	move.l	fsize,d0
	asr.l	#1,d0
	subq.l	#2,d0
.l:	move.w	2(a0),d1
	eor.w	#'!?',d1
	eor.w	d1,(a0)+
	dbf	d0,.l
	rts
nytt:	move.l	16(a1),d0
	move.l	(a1),a0
	add.l	#40,a0
	move.l	a0,a2
	move.l	(a0)+,d7
	subq.l	#1,d7
.loop:	cmp.w	(a0),d0
	beq.s	hitt
	add.l	#50,a0
	dbf	d7,.loop
	moveq	#0,d7
	add.l	#1,(a2)
	move.l	a0,senaste
	move.w	d0,(a0)+
	move.l	4(a1),a3
	move.w	2(a3),(a0)+
	move.w	6(a3),(a0)+
	move.w	10(a3),(a0)+
	move.l	8(a1),a4
	move.l	a4,20(a1)
	move.l	a4,24(a1)
	lea	20(a0),a5
.q:	move.b	(a4)+,(a0)+
	bne.s	.q
	move.l	(a3),d0
	cmp.l	4(a3),d0
	bmi.s	.w
	move.l	4(a3),d0
.w:	cmp.l	8(a3),d0
	bmi.s	.e
	move.l	8(a3),d0
.e:	move.w	d0,(a5)+
	move.l	8(a1),a4
.r:	move.b	(a4)+,(a5)+
	bne.s	.r
	moveq	#3,d7
	rts
hitt:
	move.l	a0,senaste
	addq.l	#2,a0
	lea	26(a0),a3
	moveq	#0,d0
	move.w	(a0),d0
	add.w	2(a0),d0
	add.w	4(a0),d0
	move.l	4(a1),a2
	move.l	(a2),d1
	add.l	4(a2),d1
	add.l	8(a2),d1
	cmp.l	d0,d1
	bge.s	.nej
	move.w	2(a2),(a0)+
	move.w	6(a2),(a0)+
	move.w	10(a2),(a0)+
	move.l	8(a1),a2
	move.l	a2,20(a1)
.q:	move.b	(a2)+,(a0)+
	bne.s	.q
	moveq	#1,d7
.nej:	move.l	4(a1),a0
	move.l	(a0),d0
	cmp.l	4(a0),d0
	bmi.s	.qw
	move.l	4(a0),d0
.qw:	cmp.l	8(a0),d0
	bmi.s	.qe
	move.l	8(a0),d0
.qe:	moveq	#0,d1
	move.w	(a3),d1
	cmp.l	d0,d1
	bhi.s	.ja
	rts
.ja:	move.w	d0,(a3)+
	move.l	8(a1),a0
	move.l	a0,24(a1)
.w:	move.b	(a0)+,(a3)+
	bne.s	.w
	moveq	#2,d7
	rts

snixsnox:	dc.w	0
qweewq:		dc.l	0
logo_frger:	dc.w	$002,$003
rita_bild:
	lea	$dff000,a6
;a0-pekare till bildstruct,d0 -slumpv�rde 0-255, a1=dest, a2-pek frg
	move.l	(a0)+,d1	;antal bilder
	moveq	#2,d2
	mulu	d0,d1
	moveq	#0,d4
	move.b	lastslump,d4
	move.b	d0,lastslump
	eor.b	d4,d0
	move.b	d0,lastslump+1
	mulu	d4,d2
	lsr.w	#8,d2
	add.w	d2,d2
	lea	logo_frger,a5
	move.w	(a5,d2),snixsnox
;	cmp.b	#85,d0
;	bls.s	.q
;	asl.w	#1,snixsnox
;.q:
	move.l	a2,qweewq
	lsr.w	#8,d1
	asl.w	#2,d1
	move.l	(a0,d1.w),a2
	lea	14746(a1),a3	;pic+90000
	moveq	#0,d7
	move.b	(a2),d7
	moveq	#0,d6
	move.b	2(a2),d6
	mulu	d7,d6
	move.l	(a2)+,(a3)+
	subq.b	#1,d7
	asr.l	#2,d6
	subq.b	#1,d6
.nol:	move.b	#0,(a3)+
	dbf	d7,.nol
.fl:	move.l	(a2)+,(a3)+
	dbf	d6,.fl
	moveq	#99,d7
.nol2:	move.b	#0,(a3)+
	dbf	d7,.nol2
	lea	14746(a1),a2
	moveq	#0,d7
	moveq	#0,d0
	moveq	#0,d6
	moveq	#0,d1
	move.b	(a2),d7	;bredd,bytes
	mulu	#8,d7
	subq.w	#1,d7
	move.b	1(a2),d0	;xpos start
	addq.l	#1,d0
	bclr	#0,d0
	move.b	2(a2),d6	;h�jd
	addq.l	#1,d6
	mulu	#64,d6
	addq.l	#1,d6
	move.b	3(a2),d1	;ypos start
	subq.l	#1,d1
	mulu	#42,d1
	add.l	d1,a1
	moveq	#0,d1
.mainl:
	move.l	d1,d2
	divu	#16,d2
	add.w	d2,d2
	lea	4(a2,d2.w),a3
	sub.w	d2,d2
	swap	d2
	move.w	d2,d4
	move.w	d2,d5
	and.w	#$f,d5
	move.w	#$DFC,d2
	move.l	d0,d3
	divu	#16,d3
	add.w	d3,d3
	lea	(a1,d3.w),a4
	sub.w	d3,d3
	swap	d3
	and.w	#$f,d3
	sub.b	d4,d3
	tst.b	d3
	bpl.s	.okdo
	moveq	#0,d4
	move.b	(a2),d4
	add.l	d4,a3
.okdo:	and.l	#$f,d3
	swap	d3
	ror.l	#4,d3
	or.w	d3,d2
	bsr	bltwait
	move.w	d2,$40(a6)
	move.w	#0,$42(a6)
	move.l	a3,$50(a6)
	move.l	a4,$4c(a6)
	move.l	a4,$54(a6)

	move.l	#$8000,d2
	tst.b	d5
	beq.s	.qe
	ror.w	d5,d2
.qe:	move.w	d2,$44(a6)
	move.w	d2,$46(a6)
	move.w	#40,$62(a6)
	moveq	#0,d4
	move.b	(a2),d4
	subq.b	#2,d4
	move.w	d4,$64(a6)
	move.w	#40,$66(a6)
	move.w	d6,$58(a6)
	bsr	bltwait
	addq.l	#1,d0
	cmp.b	#85,lastslump+1
	bls.s	.blaha
	addq.l	#1,d0
.blaha:	btst	#0,d0
	bne.w	.mainl
	addq.l	#1,d1
	dbf	d7,.mainl
	bsr	bltwait

	move.l	a1,a4
	moveq	#0,d7
	move.b	2(a2),d7
	addq.w	#1,d7
	move.w	d7,d5
	mulu	#42,d7
	add.l	d7,a4
	move.l	a4,a5
	add.l	d7,a4
	moveq	#0,d6
	move.b	2(a2),d6
.l:	moveq	#20,d7
;	cmp.b	#55,lastslump+1
;	bhi.s	.b2
	bra.s	.b2
.l2:	move.w	(a5)+,(a4)+
	dbf	d7,.l2
	bra.s	.b3
.b2:	moveq	#0,d2
.l5:	move.w	d2,(a4)+
	dbf	d7,.l5
	add.l	#42,a5
.b3:	sub.l	#84,a4
	sub.l	#42,a5
	moveq	#20,d7
.l3:	move.w	(a5)+,(a4)+
	dbf	d7,.l3
	sub.l	#84,a4
	sub.l	#84,a5
	dbf	d6,.l

	move.l	qweewq,a2
	move.w	snixsnox,(a2)

	rts


bltwait:
	btst	#6,$dff002
	bne.s	bltwait
	rts

;Autodoc to the DEPACK routine:
;	a0 - pointer to packed file
;	a1 - pointer to buffer for depacked file
;	bsr	DEPACK

;struct for packed file:
;	dc.l	"BPCK"	;id for depack routine
;	dc.b	k1	;control byte #1
;	dc.b	k2	;control byte #2
;	dc.w	0	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	dc.l	Size	;Unpacked size
;	...data...

;dc.b	k1,5,6		; = 5 times "chr$(6)"
;dc.b	k1,255		; = chr$(k1)
;dc.b	k2,5,6,7	; = (5*256 + 6) times "chr$(7)"
;dc.b	k2,255		; = chr$(k2)

unp_data:
	exg	a0,a1
	bsr	depack
	rts
;------------- DEPACK ROUTINE

DEPACK:
	cmp.w	#'BP',(a0)+	;BPxx (xx=CK / xx=CC)
	bne	exit_np		;not packed!
	add.l	#2,a0
	move.b	(a0)+,k1+3
	move.b	(a0)+,k2+3
	cmp.w	#0,(a0)+
	bne.w	exit_np
	move.l	(a0)+,d7	;FILESIZE,unpacked
	subq.l	#1,d7
unpack:
;flash!
;	move.w	$dff006,$dff180

	move.b	(a0)+,d0
	cmp.b	k1+3,d0
	beq.s	kontroll1
	cmp.b	k2+3,d0
	beq.s	kontroll2
	move.b	d0,(a1)+
	subq.l	#1,d7
	bpl.s	unpack
	bra	depack_ready
kontroll1:
	moveq	#0,d1
	move.b	(a0)+,d1
	cmp.b	#255,d1
	bne.s	not_kontrbyte1
	move.b	d0,(a1)+
	subq.l	#1,d7
	bpl.s	unpack
	bra	depack_ready
not_kontrbyte1:
	move.b	(a0)+,d2
	and.l	#$FF,d1
	move.l	d1,temp_d1

	add.l	#1,d7
	cmp.l	d1,d7
	bmi.w	depack_crash
	sub.l	#1,d7

	bsr	unpack_it

	move.l	temp_d1,d1
	sub.l	d1,d7
	bpl.s	unpack
	bra.w	depack_ready
kontroll2:
	moveq	#0,d1
	move.b	(a0)+,d1
	cmp.b	#255,d1
	bne.s	not_kontrbyte2
	move.b	d0,(a1)+
	subq.l	#1,d7
	bpl.s	unpack
	bra.s	depack_ready
not_kontrbyte2:
	asl.w	#8,d1
	move.b	(a0)+,d1	;d1=# of d2s,d1=word
	move.b	(a0)+,d2
	move.l	d1,temp_d1

bp_noblt:
	add.l	#1,d7
	cmp.l	d1,d7
	bmi.s	depack_crash
	sub.l	#1,d7

	bsr	unpack_it

	move.l	temp_d1,d1
	sub.l	d1,d7
	bpl.w	unpack
	bra.s	depack_ready

unpack_it: 	move.l	a1,d6
	btst	#0,d6		;even adr?
	beq.s	bp_evenadr
	move.b	d2,(a1)+	;no? fix it!
	subq.w	#1,d1
bp_evenadr:
	moveq	#0,d3
	move.b	d2,d3
	divu	#4,d1
	lsl.l	#8,d3
	move.b	d2,d3
	move.w	d3,d2
	swap	d3
	move.w	d2,d3	
	bra.s	bpfl_el
bpfl:	move.l	d3,(a1)+
bpfl_el:dbf	d1,bpfl
	swap	d1		;even up the last bytes
no_longs:
	and.l	#$ff,d3
	bra.s	bpfl_n
bpfl_l:	move.b	d3,(a1)+
bpfl_n:	dbf	d1,bpfl_l
	rts

depack_ready:
	moveq	#0,d0
	rts			;depack ready,no errors

depack_crash:
	moveq	#-2,d0
	rts
exit_np:
	move.l	#-1,d0
	rts			;depack routine error

OPEN:		EQU	-30	; d1/d2 filen/accessm($3ed=existing,$3ee=new) <d0>
CLOSE:		EQU	-36	; d1 fileh
WRITE:		EQU	-48	;d1/d2/d3 fileh/buffer/length

	even
	fname:		dc.b	'GPX:Logfile.Dat',0
	fname2:	dc.b	'GPX:GPX_Prefs.Dat',0
	even
savefile:		;autodoc: a0 ptr to 0-t filename.d0 returns
			; adr,d1 size d0=0? fail
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	12(a1),a6	;dosbase
	move.l	#$3ee,d2
	jsr	open(a6)
	tst.l	d0
	beq.s	.faila
	move.l	d0,fhandle
	move.l	d0,d1
	move.l	fsize,d3
	move.l	fmem,d2
	jsr	write(a6)
	move.l	fhandle,d1
	jsr	close(a6)
.fail:	movem.l	(sp)+,d2-d7/a0-a6
	rts
.faila:	
	moveq	#-1,d7
.l2:	move.w	#$f00,$dff180
	dbf	d7,.l2
	bra.s	.fail

version:	dc.b	'1.10',0

	even

pods:	incbin	"dh1:gfx/gf2/pods.bmap"

	section	snixdata,bss

snixus:	ds.w	1
s_times:	ds.b	12
s_matcher:	ds.b	14
s_races:	ds.b	14
s_lmatch:	ds.b	14
s_playt:	ds.b	38
s_rounds:	ds.b	14
v_tider:	ds.b	38
s_matcher2:	ds.b	14
s_races2:	ds.b	14
s_lmatch2:	ds.b	14
s_playt2:	ds.b	38
s_rounds2:	ds.b	14
v_tider2:	ds.b	38
kopia:		ds.b	28
spist:		ds.b	30
k1:	ds.l	1
k2:	ds.l	1
temp_d1:	ds.l	1
senaste:	ds.l	1
	fsize:		ds.l	1
	fhandle:	ds.l	1
	fmem:		ds.l	1
cd_snix:	ds.w	1
lastslump:	ds.w	1
podadr:	ds.l	1

;Prog END...
