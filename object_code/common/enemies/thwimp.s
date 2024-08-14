; ==================================================================================================
; ENEMY_THWIMP
;
; Variables:
;   var30: Original y-position (where it returns to after stomping)
; ==================================================================================================
enemyCode2e:
	jr z,@normalStatus
	sub ENEMYSTATUS_NO_HEALTH
	ret c

@normalStatus:
	ld e,Enemy.state
	ld a,(de)
	rst_jumpTable
	.dw @state_uninitialized
	.dw @state_stub
	.dw @state_stub
	.dw @state_stub
	.dw @state_stub
	.dw @state_stub
	.dw @state_stub
	.dw @state_stub
	.dw @state8
	.dw @state9
	.dw @stateA
	.dw @stateB
	.dw @stateC


@state_uninitialized:
	; ANTIGRAV: Bit 7 of subid = flipped thwimp
	ld e,Enemy.subid
	ld a,(de)
	and $80
	jr z,++
	ld e,Enemy.oamFlagsBackup
	ld a,(de)
	xor $40
	ld (de),a
++
	ld e,Enemy.yh
	ld a,(de)
	ld e,Enemy.var30
	ld (de),a

	ld h,d
	ld l,Enemy.counter1
	inc (hl)

	ld l,Enemy.angle
	ld (hl),ANGLE_DOWN
	jp ecom_setSpeedAndState8AndVisible


@state_stub:
	ret


; Cooldown of [counter1] frames
@state8:
	call ecom_decCounter1
	ret nz
	ld l,e
	inc (hl) ; [state]
	xor a
	ret


; Waiting for Link to approach
@state9:
	ld h,d
	ld l,Enemy.xh
	ldh a,(<hEnemyTargetX)
	sub (hl)
	add $0a
	cp $15
	ret nc

	ld l,e
	inc (hl) ; [state]

	ld l,Enemy.speedZ
	xor a
	ldi (hl),a
	ld (hl),a

	inc a
	jp enemySetAnimation


; Falling down
@stateA:
	ld e,Enemy.subid
	ld a,(de)
	and $80
	ld a,$40
	ld b,$06
	jr z,+
	call objectUpdateSpeedZ_sidescroll_givenYOffset_antigrav
	jr ++
+
	call objectUpdateSpeedZ_sidescroll_givenYOffset
++
	jr c,@landed

	ld e,Enemy.subid
	ld a,(de)
	and $80
	jr nz,@@antigrav

	; Cap speedZ to $0200 (ish... doesn't fix the low byte)
	ld a,(hl)
	cp $03
	ret c
	ld (hl),$02
	ret

@@antigrav:
	ld a,(hl)
	cp -$03
	ret nc
	ld (hl),-$02
	ret

@landed:
	call ecom_incState
	ld l,Enemy.counter1
	ld (hl),45
	ld a,SND_CLINK
	jp playSound


; Just landed. Wait for [counter1] frames
@stateB:
	call @state8
	ret nz
	jp enemySetAnimation


; Moving back up at constant speed
@stateC:
	ld e,Enemy.subid
	ld a,(de)
	and $80
	jr nz,@@antigrav

	ld h,d
	ld l,Enemy.y
	ld a,(hl)
	sub $80
	ldi (hl),a
	ld a,(hl)
	sbc $00
	ld (hl),a

@@common:
	ld e,Enemy.var30
	ld a,(de)
	cp (hl)
	ret nz

	ld l,Enemy.counter1
	ld (hl),24
	ld l,Enemy.state
	ld (hl),$08
	ret

@@antigrav:
	ld h,d
	ld l,Enemy.y
	ld a,(hl)
	add $80
	ldi (hl),a
	ld a,(hl)
	adc $00
	ld (hl),a
	jr @@common
