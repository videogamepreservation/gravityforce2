�����<�w�<�w  ��<�w�<�w�<�w�<�w�<�w�<�w
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

;Ex: fr�n cli: Urk Ule
; a0 pekar p� adr 87
; adr 87: 'Ule',10

progg:
;	lea	snix,a0

	cmp.b	#'�',(a0)
	bne.s	.n
	move.w	#-1,one_way
	addq.l	#1,a0
.n:	bsr	checkparam
	tst.l	d0
	bne.w	info
	
	bsr	opendos
	tst.w	d0
	bne.w	quit
	
	bsr	type_load

	lea	fname1,a0
	bsr	loadfile
	move.l	d1,fsize1
	move.l	d0,file1
	beq.w	error

	lea	fname2,a0
	bsr	loadfile
	move.l	d1,fsize2
	move.l	d0,file2
	beq.w	error

	bsr	type_work

	bsr	do_work

	bsr	type_save
	
	tst.w	one_way
	bne.s	.s
	lea	fname1,a0
	move.l	file1,a1
	move.l	fsize1,d0
	bsr	savefile
	tst.w	d0
	bne.w	error

.s:	lea	fname2,a0
	move.l	file2,a1
	move.l	fsize2,d0
	bsr	savefile
	tst.w	d0
	bne.w	error

	lea	ok_txt,a0
	bsr	typetxt

	bsr	closedos
quit:
	bsr	freeallminne
	rts


do_work:
	move.l	file1,a0
	move.l	fsize1,d0
	bsr	chk_checksum
	move.l	file2,a0
	move.l	fsize2,d0
	bsr	chk_checksum
	bsr	fixa_det
	move.l	file1,a0
	move.l	fsize1,d0
	bsr	fix_chksum
	move.l	file2,a0
	move.l	fsize2,d0
	bsr	fix_chksum
	tst.w	show_r
	beq.s	.ns
	bsr	show_it
.ns:	move.l	file1,a0
	move.l	fsize1,d0
	bsr	code
	move.l	file2,a0
	move.l	fsize2,d0
	bsr	code
	rts

show_it:
	move.l	file1,a0
	add.l	#40,a0
	move.l	(a0)+,d7
	bra.s	.endl
.l:	movem.l	d7/a0,-(sp)
	move.l	a0,a1
	cmp.w	#1234,(a0)
	beq.s	.skipit
	cmp.b	#'&',8(a0)
	bne.s	.n
	lea	unfair_txt,a0
	bsr	typetxt
	move.l	a1,a0
	addq.l	#1,a0
.n:	lea	8(a0),a0
	bsr	typetxt
	lea	tab_txt,a0
	bsr	typetxt
	move.l	a1,a0
	cmp.b	#'&',30(a0)
	bne.s	.n2
	lea	unfair_txt,a0
	bsr	typetxt
	move.l	a1,a0
	addq.l	#1,a0
.n2:	lea	30(a0),a0
	bsr	typetxt
	lea	lf_txt,a0
	bsr	typetxt
.skipit:movem.l	(sp)+,d7/a0
	add.l	#50,a0
.endl:	dbf	d7,.l
	lea	curs_on,a0
	bsr	typetxt
	rts

	
fixa_det:
	move.l	#0,extra
	move.l	file1,from_adr
	move.l	file2,to_adr
	bsr	do_the_shit
	move.l	extra,d0
	add.l	d0,fsize2
	tst.w	one_way
	bne.s	.ut
	move.l	#0,extra
	move.l	file2,from_adr
	move.l	file1,to_adr
	bsr	do_the_shit
	move.l	extra,d0
	add.l	d0,fsize1
.ut:	rts
do_the_shit:
	move.l	from_adr,a5
	move.l	to_adr,a6
	add.l	#40,a5
	add.l	#40,a6
	move.l	(a5)+,d7
	bra.w	.end_l
.loop:	moveq	#0,d0
	move.w	(a5),d0
	move.l	a6,a0
	move.l	(a0)+,d6
	bra.s	.el2
.fl:	cmp.w	(a0),d0
	beq.s	.found
	add.l	#50,a0
.el2:	dbf	d6,.fl
	add.l	#50,extra
	add.l	#1,(a6)
	move.w	d0,(a0)+
	move.w	2(a5),(a0)+
	move.w	4(a5),(a0)+
	move.w	6(a5),(a0)+
	lea	8(a5),a1
	bsr	cop_n
	move.w	28(a5),20(a0)
	lea	22(a0),a0
	lea	30(a5),a1
	bsr	cop_n
	add.l	#50,a5
	bra.w	.end_l
.found:	add.l	#2,a5
	add.l	#2,a0
	moveq	#0,d0
	moveq	#0,d1
	add.w	(a5),d0
	add.w	2(a5),d0
	add.w	4(a5),d0
	add.w	(a0),d1
	add.w	2(a0),d1
	add.w	4(a0),d1
	cmp.l	d1,d0
	bpl.s	.no_byt
	cmp.b	#'&',6(a0)
	beq.s	.byt
	cmp.b	#'&',6(a5)
	beq.s	.no_byt
.byt:	move.w	(a5),(a0)
	move.w	2(a5),2(a0)
	move.w	4(a5),4(a0)
	lea	6(a5),a1
	add.l	#6,a0
	bsr	cop_n
	sub.l	#6,a0
.no_byt:
	add.l	#26,a5
	add.l	#26,a0
	move.w	(a5),d0
	cmp.w	(a0),d0
	bpl.s	.ready
	cmp.b	#'&',2(a0)
	beq.s	.qbyt
	cmp.b	#'&',2(a5)
	beq.s	.ready
.qbyt:	move.w	(a5),(a0)
	move.l	a5,a1
	addq.l	#2,a1
	addq.l	#2,a0
	bsr	cop_n
.ready:	add.l	#22,a5
.end_l:	dbf	d7,.loop
	rts

cop_n:	move.l	a0,-(sp)
.ok:	move.b	(a1)+,(a0)+
	bne.s	.ok
	move.l	(sp)+,a0
	rts

fix_chksum:		;a0=ptr,d0=size
	move.l	d0,d7
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
chk_checksum:		;a0=Ptr,d0=size
	move.l	a0,-(sp)
	movem.l	d0/a0,-(sp)
	bsr	decode
	movem.l	(sp)+,d0/a0
	move.l	(a0)+,d1
	eor.l	#'SNIX',d1
	asr.l	#2,d0
	subq.l	#2,d0
.cl:	add.l	(a0)+,d1
	dbf	d0,.cl
	move.l	(sp)+,a0
	tst.l	d1
	bne.s	fel_chk
	rts
fel_chk:		;a0=ptr
	add.l	#40,a0
	move.l	(a0)+,d7
	subq.w	#1,d7
.l:	move.l	#$3a983a98,2(a0)
	move.w	#$3a98,6(a0)
	move.w	#$3a98,28(a0)
	add.l	#50,a0
	dbf	d7,.l
	rts
decode:			;a0=ptr,d0=size
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
code:			;a0=ptr,d0=size
	asr.l	#1,d0
	subq.l	#2,d0
.l:	move.w	2(a0),d1
	eor.w	#'!?',d1
	eor.w	d1,(a0)+
	dbf	d0,.l
	rts

type_load:
	lea	load_txt,a0
	bsr	typetxt
	lea	fname1,a0
	bsr	typetxt
	lea	l_txt2,a0
	bsr	typetxt
	lea	fname2,a0
	bsr	typetxt
	lea	l_txt3,a0
	bsr	typetxt
	rts
type_work:
	lea	work_txt,a0
	bsr	typetxt
	tst.w	show_r
	beq.s	.ut
	lea	show_rtxt,a0
	bsr	typetxt
.ut:	rts
type_save:
	lea	save_txt,a0
	bsr	typetxt
	rts
error:
	lea	err_txt,a0
	bsr	typetxt
	bsr	freeallminne
	bsr	closedos
	moveq	#20,d0
	rts

info:
	bsr	opendos
	lea	info_txt,a0
	bsr	typetxt
	bsr	closedos
	moveq	#5,d0
	rts

nomemquit:
;	lea	nomem,a0
;	bsr	typetxt
;	bsr	freeallminne
	moveq	#20,d0
	rts
;--------------
checkparam:
	move.l	a0,params
	moveq	#0,d0
	cmp.b	#'@',(a0)
	beq.s	.def
	cmp.b	#'?',(a0)
	beq.s	.info
	cmp.b	#11,(a0)
	bmi.s	.info
	lea	fname1,a1
	bsr	getfilename
	tst.b	fname1
	beq.s	.info
	cmp.b	#'/',-1(a0)
	beq.s	.j
	cmp.b	#':',-1(a0)
	bne.s	.n
.j:	bsr	add_f
.n:	addq.l	#1,a0
	lea	fname2,a1
	bsr	getfilename
	tst.b	fname2
	beq.s	.info
	cmp.b	#'/',-1(a0)
	beq.s	.j2
	cmp.b	#':',-1(a0)
	bne.s	.n2
.j2:	bsr	add_f
.n2:	moveq	#0,d0
	cmp.b	#'S',1(a0)
	beq.s	.show
	cmp.b	#'s',1(a0)
	bne.s	.nshow
.show:	move.w	#-1,show_r
.nshow:	rts
.info:	moveq	#-1,d0
	rts
.def:	lea	def1,a1
	lea	fname1,a0
	bsr	cop_n
	lea	def2,a1
	lea	fname2,a0
	bsr	cop_n
	move.l	params,a0
	addq.l	#1,a0
	bra.s	.n2

add_f:
	move.l	a0,-(sp)
	move.l	a1,a0
	lea	df_name,a1
	bsr	cop_n
	move.l	(sp)+,a0
	rts


getfilename:
	move.b	#32,d3
	cmp.b	#'"',(a0)
	bne.s	.not_cit
	add.l	#1,a0
	move.b	#'"',d3
.not_cit:
	move.b	(a0)+,(a1)+
	cmp.b	(a0),d3
	beq.s	.slut
	cmp.b	#10,(a0)
	beq.s	.slut
	cmp.b	#0,(a0)
	bne.s	.not_cit
.slut:	
	move.b	#0,(a1)
	cmp.b	#'"',(a0)
	bne.s	.nehe
	addq.l	#1,a0
.nehe:	moveq	#0,d0
	rts
	
;--------------
seek:		;autodoc:	a0 -adr,d0.b=seek data1,d1.b=seek data2
		;d2.b=alt data2! d3.b=term value,d4=alt term val
		; not found - d0.l=-1
	movem.l	a1-a6/d1-d7,-(sp)
.let:	cmp.b	(a0),d0
	beq.s	.found
.nope:	cmp.b	(a0),d3
	beq.s	.nf
	cmp.b	(a0),d4
	beq.s	.nf
	add.l	#1,a0
	bra.s	.let
.nf:
	move.l	#-1,d0
	bra.s	.yf
.found:
	cmp.b	1(a0),d2
	beq.s	.yf1
	cmp.b	1(a0),d1
	bne.s	.nope
.yf1:	moveq	#0,d0
.yf:	movem.l	(sp)+,a1-a6/d1-d7
	rts
	
***************

loadfile:		;autodoc: a0 ptr to 0-t filename.d0 returns
			; adr,d1 size d0=0? fail
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	a0,fname
	move.l	dosbase,a6
	move.l	#270,d0
	jsr	allocminne
	tst.l	d0
	beq.w	.fail
	add.l	#4,d0
	and.l	#$FFFFFFFC,d0
	move.l	d0,finfoblock
	move.l	#-2,d2
	move.l	fname,d1
	move.l	dosbase,a6
	jsr	lock(a6)
	move.l	d0,flock
	beq.w	.fail
	move.l	d0,d1
	move.l	finfoblock,d2
	jsr	examine(a6)
	move.l	finfoblock,a1
	move.l	124(a1),fsize
	move.l	flock,d1
	jsr	unlock(a6)
	move.l	fsize,d0
	add.l	#5000,d0	;extra minne! max 100 nya rekord
	jsr	allocminne
	tst.l	d0
	beq.s	.fail
	move.l	d0,fmem
	move.l	fname,d1
	move.l	#$3ed,d2
	jsr	open(a6)
	tst.l	d0
	beq.s	.fail
	move.l	d0,fhandle
	move.l	d0,d1
	move.l	fsize,d3
	move.l	fmem,d2
	jsr	read(a6)
	move.l	fhandle,d1
	jsr	close(a6)
	movem.l	(sp)+,d2-d7/a0-a6
	move.l	fmem,d0
	move.l	fsize,d1
	rts
.fail:
	movem.l	(sp)+,d2-d7/a0-a6
	moveq	#0,d0
	rts

savefile:	;autodoc:	a0 ptr till namn.d0=file length
				;a1 ptr till data
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	a0,fname
	move.l	a1,fmem
	move.l	d0,fsize
	move.l	dosbase,a6
	move.l	fname,d1
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
	moveq	#0,d0
	rts
.fail:
	movem.l	(sp)+,d2-d7/a0-a6
	moveq	#-1,d0
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
	jsr	input(a6)
	move.l	d0,dos_in
	beq.s	.exit
	jsr	output(a6)
	move.l	d0,dos_out
	beq.s	.exit
	moveq	#0,d0
	rts
.exit:
	moveq	#1,d0
	rts

closedos:
	move.l	dosbase,a1
	move.l	4,a6
	jsr	closelibrary(a6)
	rts
		

;-------
allocminne:		;autodoc: d0 = size,out: d0=adr,0 if fail
	movem.l	d1-d7/a0-a6,-(sp)
	lea	allocs,a0
	moveq	#19,d7
.seek:	tst.l	(a0)
	beq.s	.found
	add.l	#4,a0
	dbf	d7,.seek
.found:	move.l	d0,4(a0)
	move.l	a0,-(sp)
	move.l	#$10000,d1
	move.l	4,a6
	jsr	alloc(a6)
	move.l	(sp)+,a0
	tst.l	d0
	beq.s	.no_mem
	move.l	d0,(a0)
	bra.s	.outa
.no_mem:
	move.l	#0,4(a0)
.outa:	movem.l	(sp)+,d1-d7/a0-a6
	rts
freeallminne:		;autodoc: bsr.frees ALL allocated mem
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	4,a6
	lea	allocs,a0
.loop:	tst.l	(a0)
	beq.s	.outa
	move.l	(a0)+,a1
	move.l	(a0)+,d0
	move.l	a0,savereg
	move.l	4,a6
	jsr	freemem(a6)
	move.l	savereg,a0
	bra.s	.loop
.outa:	movem.l	(sp)+,d0-d7/a0-a6
	rts

;-----

dosname:	dc.b	'dos.library',0
*****************************

info_txt:
	dc.b	10,27,'[33m � GF2 Record Merger 1.0 �',27,'[31m'
	dc.b	$9b,'31',$43,'FreeWare!',10
	dc.b	27,'[33m �������������������������',27,'[31m',10
dc.b ' This utility takes two GF2-Logfiles, compares the records '
dc.b 'and picks',10,'the best one for each level. "Unfair" records'
dc.b ' are treated in the same way,',10,'but an "Unfair" record can never'
dc.b ' beat a "fair" one.',10,10
dc.b 27,'[33m Syntax: LogMerge <LogFile1> <LogFile2> [SHOW]',27,'[31m',10,10
dc.b ' The result is saved '
dc.b "to both logfiles, without changing each logfile's",10,"individual "
dc.b 'statistical info.',10,10,27
dc.b '[33mResult:',27,'[31m Both logfiles are updated with the latest records.',10,10
dc.b 'Option ',27,'[33mSHOW',27,'[31m lists the record holders. (No order, and no level names.)',10
dc.b 10,' If <LogFile#> ends with : or / it is assumed to be a path',10
dc.b 'and the name of the logfile is assumed to be ',27,'[33mLogFile.Dat'
dc.b 27,'[31m',10,10
dc.b 0

err_txt:
	dc.b	27,'[33m Error!',27,'[31m Quitting...',10,10,0

load_txt:
	dc.b	10,27,'[33m � GF2 Record Merger 1.0 �',27,'[31m'
	dc.b	$9b,'31',$43,'FreeWare!',10
	dc.b	27,'[33m �������������������������',27,'[31m',10
	dc.b	'First file  : ',27,'[33m',0
l_txt2:	dc.b	27,'[31m',10,'Second file : ',27,'[33m',0
l_txt3:	dc.b	27,'[31m',10,10,'� Loading...',10,0
work_txt:
	dc.b	'� Working...',10,0
show_rtxt:
	dc.b	$9b,$30,$20,$70,'� Record Holders:',$d,$9b,'57',$43,'(No order)',10,10
dc.b	27,'[33m  - Total: -',$d,$9b,'35',$43,' - Lap: -',27,'[31m',10,' ',0
tab_txt:	dc.b	$d,$9b,'35',$43,0
lf_txt:	dc.b	10,' ',0
unfair_txt:	dc.b	27,'[33mUnfair: ',27,'[31m',0
curs_on:	dc.b	$9b,$20,$70,10,0
save_txt:
	dc.b	'� Saving...',10,0
ok_txt:	dc.b	27,'[33m Ready!',27,'[31m',10,10,0

def1:	dc.b	'DF0:GF2/LogFile.Dat',0
def2:	dc.b	'DF1:GF2/LogFile.Dat',0
snix:	dc.b	'ram:q ram:a',10,0
df_name:	dc.b	'LogFile.Dat',0

	section	snix,bss

	fname:		ds.l	1	;temp...
	flock:		ds.l	1	;temp...
	finfoblock:	ds.l	1	;all of them...
	fsize:		ds.l	1
	fhandle:	ds.l	1
	fmem:		ds.l	1	
savereg:	ds.l	1
dosbase:	ds.l	1
dos_in:		ds.l	1
dos_out:	ds.l	1
allocs:
	ds.l	22		;max 20/2 allocs
show_r:	ds.w	1
	params:	ds.l	1

fsize1:	ds.l	1
fsize2:	ds.l	1
file1:	ds.l	1
file2:	ds.l	1

from_adr:	ds.l	1
to_adr:	ds.l	1
extra:	ds.l	1
one_way:	ds.w	1

fname1:	ds.b	50
fname2:	ds.b	50


