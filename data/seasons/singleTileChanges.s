singleTileChangeGroupTable:
	.dw singleTileChangeGroup0Data
	.dw singleTileChangeGroup1Data
	.dw singleTileChangeGroup2Data
	.dw singleTileChangeGroup3Data
	.dw singleTileChangeGroup4Data
	.dw singleTileChangeGroup5Data
	.dw singleTileChangeGroup6Data
	.dw singleTileChangeGroup7Data

; Data format:
; b0: Room index
; b1: Bitmask to check. If bitmask & [room flags] is nonzero, the change is applied.
;     The $f0/$f1/$f2 special cases from Ages do NOT exist in seasons unless the "AGES_ENGINE"
;     define is enabled.
; b2: Position of tile to change
; b3: New tile to put at that position

singleTileChangeGroup0Data:
	.db $9a $40 $33 $c5
	.db $52 $40 $02 $d0
	.db $52 $40 $01 $6b
	.db $52 $40 $03 $45
	.db $e9 $01 $48 $04
	.db $e9 $02 $58 $04
	.db $01 $80 $66 $04
	.db $01 $80 $65 $9c
	.db $01 $40 $66 $04
	.db $01 $40 $67 $9c
	.db $00 $00

singleTileChangeGroup1Data:
	.db $0a $80 $32 $e1
	.db $0a $80 $33 $e1
	.db $0a $80 $34 $e1
	.db $08 $40 $53 $e8
	.db $12 $40 $58 $e8
	.db $35 $40 $46 $e8
	.db $13 $01 $25 $04
	.db $42 $01 $57 $06
	.db $44 $01 $56 $06
	.db $48 $01 $35 $04
	.db $55 $01 $52 $04
	.db $55 $02 $62 $04
	.db $69 $20 $28 $e1
	.db $00 $00

singleTileChangeGroup2Data:
singleTileChangeGroup3Data:
	.db $00 $00

singleTileChangeGroup4Data:
	.db $22 $40 $4b $a2 ; Pot fall 1
	.db $21 $40 $4b $a2
	.db $15 $40 $57 $a2 ; Pot fall 2
	.db $24 $40 $57 $a2
	.db $00 $00

singleTileChangeGroup5Data:
	.db $f0 $40 $77 $6a
	.db $bc $20 $2a $53
	.db $3e $80 $5c $05
	.db $73 $80 $45 $a0
	.db $73 $80 $34 $26
	.db $99 $80 $9d $44
	.db $9a $80 $66 $45
	.db $9e $80 $9d $44
	.db $27 $80 $57 $4f
	.db $00 $00

singleTileChangeGroup6Data:
singleTileChangeGroup7Data:
	.db $00 $00
