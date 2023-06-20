exhirom

org $c1bc4a     ; Location in the Tech command stream after animation and some Charm processing.
jsl $5f0060
bit #$80        ; Test bit $80 of temp memory byte.
bne $04         ; Continue if set.
jsr $bb49       ; Else call another Tech.
nop

org $5f0060     ; Free space in expanded rom
TechRepeater:   ; As we arrive, A holds control header. X holds PC ID.
lda $aecc       ; The hook at $c1bc4a wrote over this and the next four lines.
cmp #$03        ; Compare to three.
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag for enemy.
ldx $b1f4       ; Load attacker stat block offset
lda $5e49,X     ; Load attacker's upgrade byte.
bit #$80
beq .Cleanup    ; Return if bit $80 not set.
lda $5e7c,X     ; Load attacker's temp memory byte (unused, default FF).
bit #$80
beq .Cleanup    ; Branch if bit $80 not set.
lda $ae93       ; Load animation index.
cmp #$12        ; Compare to Hypno Wave.
beq .Cleanup    ; Return if equal.
cmp #$15        ; Compare to Shield.
beq .Cleanup    ; Return if equal.
lda $b2eb       ; Load second actor ID.
cmp #$ff
bne .Cleanup    ; Return if Combo Tech.
tdc
tax
lda #$63        ; Return a value 0-99.
jsl $c1fdcb     ; RNG routine hook.
ldx $b1f4       ; Load attacker stat block offset.
cmp #$32        ; Compare RNG result to fifty.
bcs .Cleanup    ; Return if result is 50-99.
lda $5e7c,X     ; Load 2x Tech memory.
and #$7f        ; Clear bit $80. (isUpgraded, isFirstHit, isDamagingTech, isSingleTech, RNG all passed.)
sta $5e7c,X     ; Store memory.
bra .Return     ; Return without setting bit.
.Cleanup
lda $5e7c,X     ; Load 2x Tech memory.
ora #$80        ; Set bit 80.
sta $5e7c,x     ; Store 2x Tech memory.
.Return
rtl