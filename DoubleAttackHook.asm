exhirom

org $c1c011     ; Location at the end of Prepare Attack routine.
jsl $5f00c0     ; Free space in an expanded ROM.
bit #$01        ; Test bit 1 of temp memory.
bne $03         ; Branch if set.
jsr $bfaa       ; Else call a second attack.
nop

org $5f00c0
DoubleAttack:
phx
lda $aecc       ; Load attack target. The hook wrote over this and the next four lines.
cmp $03
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag
ldx $b1f4       ; Load attacker's battle stat block local offset.
lda $5e49,X     ; Load attacker's upgrade byte.
bit #$08        ; Test "2x attack" upgrade bit.
beq .Cleanup    ; Return if not set.
lda $5e7c,X     ; Load attacker's temp memory byte (unused, default FF).
bit #$01
beq .Cleanup    ; Return if not set.
and #$fe        ; Else clear bit 01. (isUpgraded, isFirstHit both passed.)
sta $5e7c,X     ; Store memory.
bra .Return     ; Return without setting bit 01.
.Cleanup
lda $5e7c,X     ; Load 2x attack memory.
ora #$01        ; Set bit 01.
sta $5e7c,x     ; Store 2x attack memory.
.Return
plx
rtl
