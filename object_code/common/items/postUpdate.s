; Unlike "itemCodeXX", "itemCodeXXPost" functions run after all other objects have updated and
; aren't subject to certain conditions that would otherwise disable updating of items.
;
; This file starts with some helper functions but see below for the "itemCodeXXPost" functions.


;;
; Used for sword, cane of somaria, rod of seasons. Updates animation, deals with
; destroying tiles?
;
updateSwingableItemAnimation:
	ld l,Item.animParameter

	cp ITEM_CANE_OF_SOMARIA
	jr z,label_07_227
	cp ITEM_ROD_OF_SEASONS
	jr z,label_07_227

	bit 6,(hl)
	jr z,label_07_227

	res 6,(hl)
	ld a,(hl)
	and $1f
	cp $10
	jr nc,+
	ld a,(w1Link.direction)
	add a
+
	and $07
	push hl
	call tryBreakTileWithSword_calculateLevel
	pop hl

label_07_227:
	ld c,$10
	ld a,(hl)
	and $1f
	cp c
	jr nc,+

	srl a
	ld c,a
	ld a,(w1Link.direction)
	add a
	add a
	add c
	ld c,$00
+
	push af
	ld hl,@data
	ld a,(wAntigravState)
	or a
	jr z,+
	ld hl,@invertedData
+
	pop af
	rst_addAToHl
	ld a,(hl)
	and $f0
	swap a
	add c
	ld e,Item.var30
	ld (de),a

	ld a,(hl)
	and $07
	jp itemSetAnimation


; For each byte:
;  Bits 4-7: value for Item.var30?
;  Bits 0-2: Animation index?
@data:
	.db $02 $41 $80 $c0 $10 $51 $92 $d2
	.db $26 $65 $a4 $e4 $30 $77 $b6 $f6

	.db $00 $11 $22 $33 $44 $55 $66 $77

@invertedData:
	.db $06 $47 $80 $c0 $14 $53 $92 $d2
	.db $22 $63 $a4 $e4 $34 $75 $b6 $f6

	.db $00 $11 $22 $33 $44 $55 $66 $77

;;
; Analagous to updateSwingableItemAnimation, but specifically for biggoron's sword
;
updateBiggoronSwordAnimation:
	ld b,$00
	ld l,Item.animParameter
	bit 6,(hl)
	jr z,+
	res 6,(hl)
	inc b
+
	ld a,(hl)
	and $0e
	rrca
	ld c,a
	ld a,(w1Link.direction)
	cp $01
	jr nz,+
	ld a,c
	jr ++
+
	inc a
	add a
	sub c
++
	and $07
	bit 0,b
	jr z,++

	push af
	ld c,a
	ld a,BREAKABLETILESOURCE_SWORD_L2
	call tryBreakTileWithSword
	pop af
++
	ld e,Item.var30
	ld (de),a
	jp itemSetAnimation

;;
; ITEM_MAGNET_GLOVES
;
itemCode08Post:
	call cpRelatedObject1ID
	jp nz,itemDelete

	ld hl,w1Link.yh
	call objectTakePosition
	ld a,(wFrameCounter)
	rrca
	rrca
	ld a,(w1Link.direction)
	adc a
	ld e,Item.var30
	ld (de),a
	jp itemSetAnimation

;;
; ITEM_SLINGSHOT
;
itemCode13Post:
	call cpRelatedObject1ID
	jp nz,itemDelete

	ld hl,w1Link.yh
	call objectTakePosition
	ld a,(w1Link.direction)
	ld e,Item.var30
	ld (de),a
	jp itemSetAnimation

;;
; ITEM_FOOLS_ORE
;
itemCode1ePost:
	call cpRelatedObject1ID
	jp nz,itemDelete

	ld l,Item.animParameter
	ld a,(hl)
	and $06
	add a
	ld b,a
	ld a,(w1Link.direction)
	add b
	ld e,Item.var30
	ld (de),a
	ld hl,swordArcData
	jr itemSetPositionInSwordArc

;;
; ITEM_PUNCH
;
itemCode00Post:
itemCode02Post:
	ld a,(w1Link.direction)
	add $18
	ld hl,swordArcData
	jr itemSetPositionInSwordArc

;;
; ITEM_BIGGORON_SWORD
;
itemCode0cPost:
	call cpRelatedObject1ID
	jp nz,itemDelete

	call updateBiggoronSwordAnimation
	ld e,Item.var30
	ld a,(de)
	ld hl,biggoronSwordArcData
	call itemSetPositionInSwordArc
	jp itemCalculateSwordDamage

;;
; ITEM_CANE_OF_SOMARIA
; ITEM_SWORD
; ITEM_ROD_OF_SEASONS
;
itemCode04Post:
itemCode05Post:
itemCode07Post:
	call cpRelatedObject1ID
	jp nz,itemDelete

	call updateSwingableItemAnimation

	ld a,(wAntigravState)
	or a
	ld hl,swordArcData
	jr z,+
	ld hl,invertedSwordArcData
+
	ld e,Item.var30
	ld a,(de)
	call itemSetPositionInSwordArc

	jp itemCalculateSwordDamage

;;
; @param	a	Index for table 'hl'
; @param	hl	Usually points to swordArcData
itemSetPositionInSwordArc:
	add a
	rst_addDoubleIndex

;;
; Copy Link's position (accounting for raised floors, with Z position 2 higher than Link)
;
; @param	hl	Pointer to data for collision radii and position offsets
itemInitializeFromLinkPosition:
	ld e,Item.collisionRadiusY
	ldi a,(hl)
	ld (de),a
	inc e
	ldi a,(hl)
	ld (de),a

	; Y
.ifdef ROM_AGES
	ld a,(wLinkRaisedFloorOffset)
	ld b,a
	ld a,(w1Link.yh)
	add b
.else
	ld a,(w1Link.yh)
.endif

	add (hl)
	ld e,Item.yh
	ld (de),a

	; Sword Y Offset is off in sidescrolling rooms for some reason (I can't figure out why??) so
	; fix it here.
	ld a,(wAntigravState)
	cp 1
	jr nz,++
	ld a,(de)
	add 4
	ld (de),a
++

	; X
	inc hl
	ld e,Item.xh
	ld a,(w1Link.xh)
	add (hl)
	ld (de),a

	; Z
	ld a,(w1Link.zh)
	ld e,Item.zh
	sub $02
	ld (de),a
	ret


; Each row probably corresponds to part of a sword's arc? (Also used by punches.)
; b0/b1: collisionRadiusY/X
; b2/b3: Y/X offsets relative to Link
swordArcData:
	.db $09 $06 $fe $10 ; 0x00
	.db $06 $09 $f2 $00 ; 0x01
	.db $09 $06 $00 $f1 ; 0x02
	.db $06 $09 $f2 $00 ; 0x03

	.db $07 $07 $f5 $0d ; 0x04
	.db $07 $07 $f5 $0d ; 0x05
	.db $07 $07 $11 $f3 ; 0x06
	.db $07 $07 $f5 $f3 ; 0x07

	.db $09 $06 $ef $fc ; 0x08
	.db $06 $09 $02 $13 ; 0x09
	.db $09 $06 $15 $03 ; 0x0a
	.db $06 $09 $02 $ed ; 0x0b

	.db $09 $06 $f6 $fc ; 0x0c
	.db $04 $09 $02 $0c ; 0x0d
	.db $09 $06 $10 $03 ; 0x0e
	.db $06 $09 $02 $f4 ; 0x0f

	.db $09 $09 $ef $fc ; 0x10
	.db $09 $09 $f2 $10 ; 0x11
	.db $09 $09 $02 $13 ; 0x12
	.db $09 $09 $12 $10 ; 0x13
	.db $09 $09 $15 $03 ; 0x14
	.db $09 $09 $11 $f3 ; 0x15
	.db $09 $09 $02 $ed ; 0x16
	.db $09 $09 $f5 $f3 ; 0x17
	.db $05 $05 $f4 $fd ; 0x18
	.db $05 $05 $00 $0c ; 0x19
	.db $05 $05 $0c $03 ; 0x1a
	.db $05 $05 $00 $f4 ; 0x1b

invertedSwordArcData:
	; Frame 0 (up/right/down/left)
	.db $09, $06, -2, -$10 ; 0x00
	.db $06, $09, 14, $00 ; 0x01
	.db $09, $06, -5, 15 ; 0x02
	.db $06, $09, 14, $00 ; 0x03

	; Frame 1
	.db $07, $07, -16, -$0d ; 0x04
	.db $07, $07, 11, $0d ; 0x05
	.db $07, $07, 13, 13 ; 0x06
	.db $07, $07, 11, $f3 ; 0x07

	; Frame 2
	.db $09, $06, -21, 3 ; 0x08
	.db $06, $09, -10, $13 ; 0x09
	.db $09, $06, 17, -4 ; 0x0a
	.db $06, $09, -10, $ed ; 0x0b

	; Frame 3
	.db $09, $06, -16, 3 ; 0x0c
	.db $04, $09, -10, $0c ; 0x0d
	.db $09, $06, 12, -4 ; 0x0e
	.db $06, $09, -10, $f4 ; 0x0f

	; Spin?
	.db $09 $09 $eb $fc ; 0x10
	.db $09 $09 $ee $10 ; 0x11
	.db $09 $09 $fe $13 ; 0x12
	.db $09 $09 $0e $10 ; 0x13
	.db $09 $09 $11 $03 ; 0x14
	.db $09 $09 $0d $f3 ; 0x15
	.db $09 $09 $fe $ed ; 0x16
	.db $09 $09 $f1 $f3 ; 0x17

	.db $05 $05 $f4 $fd ; 0x18
	.db $05 $05 $00 $0c ; 0x19
	.db $05 $05 $0c $03 ; 0x1a
	.db $05 $05 $00 $f4 ; 0x1b

biggoronSwordArcData:
	.db $0b $0b $ef $fe
	.db $09 $0c $f2 $10
	.db $0b $0b $02 $13
	.db $0c $09 $12 $10
	.db $0b $0b $15 $01
	.db $09 $0c $11 $f3
	.db $0b $0b $02 $ed
	.db $0c $09 $f5 $f3
