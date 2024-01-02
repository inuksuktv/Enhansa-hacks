exhirom

org $c1c011     ; Location at the end of Prepare Attack routine.
jsl $5f0490     ; Free space in an expanded ROM.
bit #$01        ; Test bit 1 of temp memory.
bne $03         ; Branch if set.
jsr $bfaa       ; Else call a second attack.
nop

org $5f0490
DoubleAttack:
php
phx
phy
lda $aecc       ; Load attack target. The hook wrote over this and the next four lines.
cmp $03
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag
.isAlive
ldx $b1f6       ; Load defender's stat block offset.
ldy $5e30,X     ; Load defender's current HP.
cpy #$0000      ; Compare to zero.
beq .Cleanup    ; Return if enemy is dead.
.isFirstAttack
ldx $b1f4       ; Load attacker's battle stat block offset.
lda $5e7c,X     ; Load attacker's temporary memory byte (unused, default FF).
bit #$01
beq .Cleanup    ; Return if not set.
.isUpgraded
lda $5e49,X     ; Load attacker's upgrade byte.
bit #$08        ; Test "2x attack" upgrade bit.
beq .NoUpgrade
.WithUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb
beq .Success    ; Branch to 2x attack if (isUpgraded, isEquipped) passed.
bra .RNG        ; Branch to RNG if only (isUpgraded) passed.
.NoUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb        ; Compare to PrismSpecs
bne .Cleanup    ; Return if not equipped.
.RNG
tdc
tax
lda #$64        ; Return a value 0-99.
jsl $c1fdcb     ; Call RNG routine.
ldx $b1f4       ; Load attacker stat block offset.
cmp #$32        ; Compare RNG result to fifty.
bcs .Cleanup    ; Return if result is 50-99.
.Success
lda $5e7c,X     ; Load temporary memory.
and #$fe        ; Clear bit 01.
sta $5e7c,X     ; Store memory.
bra .Return     ; Return without setting bit 01 so that second attack fires.
.Cleanup
ldx $b1f4       ; Load attacker stat block offset.
lda $5e7c,X     ; Load 2x attack memory.
ora #$01        ; Set bit 01.
sta $5e7c,x     ; Store 2x attack memory.
.Return
ply
plx
plp
rtl
