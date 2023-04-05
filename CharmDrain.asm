hirom

org $01d3bf ; The old Stealing routine. Tech mode 06 for old Charm.
nop #53     ; NOP it out.

org $01d9df ; Pointer for Tech mode 04.
db $c0, $d3 ; Pointer to new Drain routine.

org $01d3bf
rts         ; Failsafe return for anything calling the old Stealing routine.
DrainMode:
jsr $e9a3   ; Get attacker's stat block offset.
.LoopStart
jsr $e9b8   ; Get defender's stat block offset.
jsr $d14f   ; Get byte 2 and 3 of effect header.
lda $16     ; Load HP/MP drain mode.
sta $1e
sta $20
and #$80    ; Test HP mode.
beq .MPDrain
lda #$03    ; Load three.
sta $1a     ; Store HP stat offset.
; Calculate damage and store to $00.
jsr $e7cb   ; Jump into the Drain execution routine after the damage calculation.
lda $ad9b   ; Load effect header index.
inc a       ; Increment.
sta $ad9b   ; Store it.
.MPDrain
lda $1e     ; Load HP/MP drain mode.
and #$40    ; Test MP mode.
beq $08     ; Branch if not set.
lda #$07    ; Load seven.
sta $1a     ; Store MP stat offset.
lda #$14    ; Load twenty.
sta $16     ; Store to drain mode?
; Calculate damage and store to $00.
jsr $e7cb   ; Jump into the Drain execution routine after the damage calculation.
jsr $d508   ; Load attack data.
dec $ad8d   ; Decrement affected unit counter.
lda $ad8d   ; Load it.
bne .LoopStart
lda #$00
sta $b200
rts
