;;
; ITEM_FEATHER ($17)
parentItemCode_feather:
	ld e,Item.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2

@state0:

.ifdef ROM_AGES
	call isLinkUnderwater
	jr nz,@deleteParent
.endif

	; Can't use the feather while using the switch hook
	ld a,(w1ParentItem2.id)
	cp ITEM_SWITCH_HOOK
	jr z,@deleteParent

	; No jumping in minecarts / on companions
	ld a,(wLinkObjectIndex)
	rrca
	jr c,@deleteParent

	; No jumping when holding something?
	ld a,(wLinkGrabState)
	or a
	jr nz,@deleteParent

	call isLinkInHole
	jr c,@deleteParent

	ld hl,wLinkSwimmingState
	ldi a,(hl)
	; Check wMagnetGloveState as well
	or (hl)
	jr nz,@deleteParent

	ld a,(wLinkInAir)
	add a
	jr c,@deleteParent

	add a
	jr c,@state1
	jr nz,@deleteParent

	ld a,(w1Link.zh)
	or a
	jr nz,@deleteParent

	; Jump higher in sidescrolling rooms
	ld bc,$fe20
	ld a,(wActiveGroup)
	cp FIRST_SIDESCROLL_GROUP
	jr c,++
	ld bc,$fdd0
	ld a,(wAntigravState)
	or a
	jr z,++
	ld bc,$230
++
	ld hl,w1Link.speedZ
	ld (hl),c
	inc l
	ld (hl),b

	ld a,$01

	ld a,(wFeatherLevel)
	cp $02
	ld a,$41
	jr nc,++
	ld a,$01
++
	ld (wLinkInAir),a
	jr c,@deleteParent

	ld e,Item.state
	ld a,$01
	ld (de),a
	ret

@deleteParent:
	jp clearParentItem

@state1:
	ld a,(wLinkInAir)
	bit 5,a
	jr nz,@deleteParent
	or a
	jr z,@deleteParent

	call parentItemCheckButtonPressed
	jr nz,++

	; Remember that the button was released
	ld a,1
	ld e,Item.var38
	ld (de),a
	jr @doneCheckingButton
++
	; Check if button was pressed twice
	ld e,Item.var38
	ld a,(de)
	or a
	jr z,@doneCheckingButton

	; Activate antigrav
	ld a,2
	ld e,Item.state
	ld (de),a
	ret

@doneCheckingButton:
	; Check if moving laterally
	ld a,(w1Link.angle)
	inc a
	jr z,+
	ld e,Item.var39
	ld a,1
	ld (de),a
+
	call @checkForInflection
	ret nz

	; Time to use cape, if button was held
	ld e,Item.var38
	ld a,(de)
	or a
	jr nz,@deleteParent

	; Speed returned from @checkForInflection
	ld hl,w1Link.speedZ
	ld (hl),c
	inc l
	ld (hl),b

	push de
	ld d,>w1Link
	ld a,LINK_ANIM_MODE_ROCS_CAPE
	call specialObjectSetAnimation
	pop de
	ld hl,wLinkInAir
	set 5,(hl)
	ld a,SND_THROW
	call playSound
	jp @deleteParent


; @param[out]	zflag	z if inflection reached
; @param[out]	bc	Vertical speed to use
@checkForInflection:
	ld a,(wAntigravState)
	cp 1
	jr z,@@inverted

	ld hl,w1Link.speedZ
	ldi a,(hl)
	ld h,(hl)
	bit 7,h
	ret nz

	ld l,a
	ld bc,$0100
	call compareHlToBc
	inc a
	jr z,@@notYet

	ld bc,-$80
	xor a
	ret

@@inverted:
	ld hl,w1Link.speedZ
	ldi a,(hl)
	ld h,(hl)
	bit 7,h
	jr z,@@notYet

	ld l,a
	ld bc,-$0100
	call compareHlToBc
	dec a
	jr z,@@notYet

	ld bc,$80
	xor a
	ret

@@notYet:
	or d
	ret



@state2:
	ld a,(wFeatherLevel)
	cp $03
	jp c,@deleteParent

	call parentItemCheckButtonPressed
	jp z,@deleteParent

	; Trigger antigrav
	ld a,(wTilesetFlags)
	bit TILESETFLAG_BIT_SIDESCROLL,a
	jr nz,@sidescroll

	; Top-down
	; Can't trigger antigrav after moving laterally, to prevent softlocks
	ld e,Item.var39
	ld a,(de)
	or a
	jp nz,@deleteParent

	ld a,LINK_STATE_BOUNCING_ON_TRAMPOLINE
	ld (wLinkForceState),a

	; Write $00 to wcc50 to allow the warp to occur, $01 to block it.
	; Allow it to occur only when in the dungeon.
	ld a,(wDungeonIndex)
	inc a
	ld a,$00
	jr nz,+
	ld a,$01
+
	ld (wcc50),a

	jp @deleteParent

@sidescroll:
	; Flip antigrav state
	ld a,(wAntigravState)
	xor 1
	ld (wAntigravState),a

	; Initial upward/downward speed
	ld bc,$100
	jr z,+
	ld bc,-$100
+
	ld hl,w1Link.speedZ
	ld (hl),c
	inc l
	ld (hl),b

	call antigravStateChanged
	jp @deleteParent
