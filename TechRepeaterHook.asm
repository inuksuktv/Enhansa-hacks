exhirom

org $c1bc4a     ; Location in the Tech command stream after animation and some Charm processing.
jsl $5f0080
bit #$80        ; Test bit $80 of temp memory byte.
bne $03         ; Continue if set.
jsr $bb49       ; Else call another Tech.
nop

org $5f0080     ; Free space in expanded rom
TechRepeater:   ; As we arrive, A holds control header. X holds PC ID.
lda $b1be,X     ; Load attacker's battle ID.
xba
lsr
tax             ; Convert battle ID to stat block offset.
lda $aecc       ; The hook at $c1bc4a wrote over this and the next four lines.
cmp #$03        ; Compare to three.
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag for enemy.
lda $5e7c,X     ; Load attacker's temp memory byte (unused, default FF).
bit #$80        ; Test 2x Tech bit.
beq .Cleanup    ; Branch if not set.
and #$7f        ; Else clear bit 80.
sta $5e7c,X     ; Store memory.
bra .Return
.Cleanup
lda $5e7c,X     ; Load 2x Tech memory.
ora #$80        ; Set bit 80.
sta $5e7c,x     ; Store 2x Tech memory.
.Return
rtl