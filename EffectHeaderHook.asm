exhirom

org $01d6fa ; Location of setup for Attack Effect routine.
jsl $5f0110 ; Jump to free space in an expanded ROM bank.
nop #6      ; The setup is ten bytes total. Setup moved to the cleanup section of the child routine. The routine call is at $c1d704 JSR.W ($d9d7,X).

org $5f0110
EffectHeaderHook:
php             ; Push flags.
.Marle
lda $b18b       ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
sta $00         ; Store it.
cmp #$01        ; Compare to one.
bne .Cleanup    ; Branch if not Marle.
lda $b18c       ; Load control header.
cmp #$09        ; Compare to 09.
bne .Cleanup    ; Branch if Tech is not Aura.
lda $00         ; Load PC ID.
rep #$20        ; Set A 16-bit.
xba
lsr a
tax             ; Convert to stat block offset.
tdc
sep #$20        ; Set A 8-bit
lda $5e49,X     ; Load Marle's upgrade memory byte.
bit #$01
beq .Cleanup    ; Branch if bit 01 not set.
lda #$02        ; (isMarle, isAura, isUpgraded all passed)
sta $aee9       ; Set status mode to 02.
lda #$40
sta $aeea       ; Set status bitflag to $40 (Regen).
lda #$20
sta $aeed       ; Set always hits flag.
bra .Cleanup
.Cleanup
plp             ; Pull flags.
lda $aee6       ; Load Tech mode.
rep #$20        ; Set A 16-bit.
asl a           ; Mode*2.
tax             ; Use as index.
tdc
sep #$20        ; Set A 8-bit.
rtl             ; Return to indirect indexed JSR to resolve Tech effect.