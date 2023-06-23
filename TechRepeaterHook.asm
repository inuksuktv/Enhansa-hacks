exhirom

org $c1bc4a     ; Location in the Tech command stream after animation and some Charm processing.
jsl $5f0050
bit #$80        ; Test bit $80 of temp memory byte.
bne $04         ; Continue if set.
jsr $bb93       ; Else call another Tech.
nop

org $5f0050     ; Free space in expanded rom
TechRepeater:   ; As we arrive, A holds control header. X holds PC ID.
php
phx
phy
lda $aecc       ; The hook at $c1bc4a wrote over this and the next four lines.
cmp #$03        ; Compare to three.
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag for enemy.
.isSingleTech
lda $b2eb       ; Load second actor ID.
cmp #$ff
beq .FirstAttack ; Continue if Single Tech.
jmp .Cleanup    ; Return if Combo Tech.
.FirstAttack
ldx $b1f4       ; Load attacker's stat block offset.
lda $5e7c,X     ; Load attacker's temporary memory byte (unused, default FF).
bit #$80
bne .isUpgraded
jmp .Cleanup    ; Return if bit $80 not set.
.isUpgraded
lda $5e49,X     ; Load attacker's upgrade byte.
bit #$80
beq .NoUpgrade  ; Return if bit $80 not set.
.WithUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb        ; Compare to Prism Specs.
beq .TestMagic  ; Branch to Branch to determine Tech if talented and Prism Specs equipped.
bra .RNG        ; Branch to RNG if talented and Prism Specs not equipped.
.NoUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb        ; Compare to Prism Specs
beq .RNG
jmp .Cleanup    ; Return if not equipped.
.RNG
tdc
tax
lda #$63        ; Return a value 0-99.
jsl $c1fdcb     ; RNG routine hook.
ldx $b1f4       ; Load attacker stat block offset.
cmp #$32        ; Compare RNG result to fifty.
bcc .TestMagic  ; Test isMagicTech if less than fifty.
jmp .Cleanup    ; Else return.
.TestMagic
lda $b2ea       ; Load actor's ID.
cmp #$00        ; Compare to Crono.
bne .Marle
lda $ae93       ; Load animation index.
cmp #$02        ; Compare to Slash.
beq .Success
cmp #$03        ; Compare to Lightning.
beq .Success
cmp #$05        ; Compare to Lightning 2.
beq .Success
cmp #$08        ; Compare to Luminaire.
beq .Success
bra .Cleanup
.Marle
cmp #$01        ; Compare to Marle.
bne .Lucca
lda $ae93       ; Load animation index.
cmp #$0c        ; Compare to Ice.
beq .Success
cmp #$0f        ; Compare to Ice 2.
beq .Success
bra .Cleanup
.Lucca
cmp #$02        ; Compare to Lucca.
bne .Robo
lda $ae93       ; Load animation index.
cmp #$13        ; Compare to Fire.
beq .Success
cmp #$16        ; Compare to Fire 2.
beq .Success
cmp #$18        ; Compare to Flare.
beq .Success
bra .Cleanup
.Robo
cmp #$03        ; Compare to Robo.
bne .Frog
lda $ae93       ; Load animation index.
cmp #$1c        ; Compare to Laser Spin.
beq .Success
cmp #$1f        ; Compare to Area Bomb.
beq .Success
cmp #$20        ; Compare to Shock.
beq .Success
bra .Cleanup
.Frog
cmp #$04        ; Compare to Frog.
bne .Ayla
lda $ae93       ; Load animation index.
cmp #$23        ; Compare to Water.
beq .Success
cmp #$26        ; Compare to Water 2.
beq .Success
bra .Cleanup
.Ayla
cmp #$05        ; Compare to Ayla.
bne .Magus
lda #$ae93      ; Load animation index.
cmp #$2f        ; Compare to Tail Spin.
beq .Success
bra .Cleanup
.Magus
lda $ae93       ; Load animation index.
cmp #$36        ; Compare to Barrier.
beq .Cleanup
cmp #$35        ; Compare to Vamp.
beq .Cleanup
cmp #$37        ; Compare to Black Hole.
beq .Cleanup
.Success
lda $5e7c,X     ; Load 2x Tech memory.
and #$7f        ; Clear bit $80.
sta $5e7c,X     ; Store memory.
bra .Return     ; Return without setting bit.
.Cleanup
lda $5e7c,X     ; Load 2x Tech temporary memory.
ora #$80        ; Set bit 80.
sta $5e7c,x     ; Store 2x Tech temporary memory.
.Return
ply
plx
plp
rtl