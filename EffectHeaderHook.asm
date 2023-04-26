exhirom

org $c1d6fa     ; Location of setup for Attack Effect routine.
jsl $5f0110     ; Jump to free space in an expanded ROM bank.
nop #6          ; The setup is ten bytes total. Setup moved to the cleanup section of the child routine. The routine call is at $c1d704 JSR.W ($d9d7,X).

org $5f0110
EffectHeaderHook:
php             ; Push flags.
lda $b18b       ; Load attacker's battle ID.
sta $00         ; Store it.
.Crono
tax
lda $aeff,X     ; Load PC ID.
sta $02
cmp #$00        ; Compare to zero.
bne .Marle      ; Branch if not Crono.
.Cyclone
lda $b2c8       ; Load effect header.
cmp #$01        ; Compare to one.
bne .Marle      ; Branch if Tech is not Cyclone.
lda $261c       ; Load Crono's upgrade memory byte.
bit #$01        ; Test bit $01.
beq .Marle      ; Branch if bit $01 not set.
lda $aeef       ; Load Tech Power (isCrono, isCyclone, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
bra .Marle
.Marle
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$01        ; Compare to one.
bne .Lucca      ; Branch if not Marle.
.Aura
lda $b2c8       ; Load effect header.
cmp #$09        ; Compare to nine.
bne .Lucca      ; Branch if Tech is not Aura.
lda $266c       ; Load Marle's upgrade memory byte.
bit #$01
beq .Lucca      ; Branch if bit 01 not set.
lda #$02        ; (isMarle, isAura, isUpgraded all passed)
sta $aee9       ; Set status mode to 02.
lda #$40
sta $aeea       ; Set status bitflag to $40 (Regen).
bra .Lucca
.Lucca
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$02        ; Compare to two.
bne .Robo       ; Branch if not Lucca.
.HypnoWave
lda $b2c8       ; Load effect header.
cmp #$12        ; Compare to $12
bne .Robo       ; Branch if Tech is not Hypno Wave
lda $26bc       ; Load Lucca's upgrade memory byte.
bit #$01
beq .Robo       ; Branch if bit 01 not set.
lda $aeed       ; (isLucca, isHypnoWave, isUpgraded all passed.)
ora #$20
sta $aeed       ; Set always hit flag.
bra .Robo
.Robo
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$03        ; Compare to three.
bne .Frog       ; Branch if not Robo.
.LaserSpin
lda $b2c8       ; Load effect header.
cmp $1b
bne .Frog       ; Branch if Tech is not Laser Spin.
lda $270c       ; Load Robo's upgrade memory byte.
bit #$01
beq .Frog
lda $aeef       ; Load Tech Power (isRobo, isLaserSpin, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
.Frog
.Ayla
.Magus
.Cleanup
plp             ; Pull flags.
lda $aee6       ; Load Tech mode.
rep #$20        ; Set A 16-bit.
asl a           ; Mode*2.
tax             ; Use as index.
tdc
sep #$20        ; Set A 8-bit.
rtl             ; Return to indirect indexed JSR to resolve Tech effect.